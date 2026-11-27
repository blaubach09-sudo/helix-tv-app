//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI

struct NewEpisodesLibrary: BaseItemKindLibrary {

    let libraryItemTypes: [BaseItemKind] = [.episode]
    let parent: TitledLibraryParent = .init(displayTitle: "New episodes", id: "helix-new-episodes")

    func shouldRefreshForUserDataChange(environment: Empty) -> Bool {
        true
    }

    func retrievePage(
        environment: Empty,
        pageState: LibraryPageState
    ) async throws -> [ItemPatch] {
        var parameters = Paths.GetItemsParameters()
        parameters.enableUserData = true
        parameters.fields = PosterSubtitleField.itemFields
        parameters.includeItemTypes = [.episode]
        parameters.isPlayed = false
        parameters.isRecursive = true
        parameters.limit = pageState.pageSize * 4 // Helix TV: over-fetch, then keep one card per show
        parameters.sortBy = [.dateCreated]
        parameters.sortOrder = [.descending]
        parameters.startIndex = pageState.pageOffset
        parameters.userID = pageState.userSession.user.id

        // Helix TV: one card per show — the earliest unplayed new episode of each series, so a
        // three-episode drop shows one "S4:E17" card instead of three; later pages are not needed.
        guard pageState.pageOffset == 0 else { return [] }

        let request = Paths.getItems(parameters: parameters)
        let response = try await pageState.userSession.client.send(request)
        let patches = try pageState.items(from: response)

        var bestBySeries: [String: Int] = [:]
        var order: [String] = []
        for (index, patch) in patches.enumerated() {
            let item = patch.value
            let key = item.seriesID ?? item.id ?? String(index)
            if let existing = bestBySeries[key] {
                let current = patches[existing].value
                let lhs = (item.parentIndexNumber ?? .max, item.indexNumber ?? .max)
                let rhs = (current.parentIndexNumber ?? .max, current.indexNumber ?? .max)
                if lhs < rhs {
                    bestBySeries[key] = index
                }
            } else {
                bestBySeries[key] = index
                order.append(key)
            }
        }
        return order.compactMap { bestBySeries[$0] }.map { patches[$0] }
    }
}
