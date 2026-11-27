//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import Defaults
import Foundation
import JellyfinAPI

/// Helix TV: the phone's "Continue Watching" row = in-progress items first, then Next Up for the shows
/// you are watching, de-duplicated — the same list the Apple TV hero shows, so the row never empties
/// just because the last episode was finished. Single page.
struct ContinueWatchingLibrary: BaseItemKindLibrary {

    let libraryItemTypes: [BaseItemKind] = [.episode, .movie, .video]
    let parent: TitledLibraryParent = .init(displayTitle: "Continue Watching", id: "helix-continue-watching")

    func shouldRefreshForUserDataChange(environment: Empty) -> Bool {
        true
    }

    func retrievePage(
        environment: Empty,
        pageState: LibraryPageState
    ) async throws -> [ItemPatch] {
        guard pageState.pageOffset == 0 else { return [] }

        var resumeParameters = Paths.GetResumeItemsParameters()
        resumeParameters.enableUserData = true
        resumeParameters.fields = PosterSubtitleField.itemFields
        resumeParameters.limit = pageState.pageSize
        resumeParameters.mediaTypes = [.video]
        resumeParameters.userID = pageState.userSession.user.id

        var nextUpParameters = Paths.GetNextUpParameters()
        nextUpParameters.enableRewatching = Defaults[.Customization.Home.resumeNextUp]
        nextUpParameters.enableUserData = true
        nextUpParameters.fields = PosterSubtitleField.itemFields
        nextUpParameters.limit = pageState.pageSize
        let maxNextUp = Defaults[.Customization.Home.maxNextUp]
        if maxNextUp > 0 {
            nextUpParameters.nextUpDateCutoff = Date.now.addingTimeInterval(-maxNextUp)
        }

        async let resumeResponse = pageState.userSession.client.send(Paths.getResumeItems(parameters: resumeParameters))
        async let nextUpResponse = pageState.userSession.client.send(Paths.getNextUp(parameters: nextUpParameters))

        let resume = try await pageState.items(from: resumeResponse)
        let nextUp = try await pageState.items(from: nextUpResponse)

        var seen = Set(resume.compactMap(\.value.id))
        var merged = resume
        for patch in nextUp {
            guard let id = patch.value.id, !seen.contains(id) else { continue }

            seen.insert(id)
            merged.append(patch)
        }
        return merged
    }
}
