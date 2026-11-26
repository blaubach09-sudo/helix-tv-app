//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import Combine
import Foundation
import JellyfinAPI
import SwiftUI

/// Helix TV: publishes an "Up next" card as an overlay action during the final
/// seconds of an episode when the queue already knows the next item. The card is
/// auto-focused by the overlay action machinery, so a centre click plays the next
/// episode immediately; Menu dismisses it for this item.
@MainActor
final class UpNextObserver {

    static let leadTime: Duration = .seconds(20)

    private let store: VideoPlayerOverlayActionStore
    private weak var item: MediaPlayerItem?
    private var observations: Set<AnyCancellable> = []
    private var publishedID: UUID?
    private var isDismissed = false

    init?(item: MediaPlayerItem) {
        guard let mediaSession = item.mediaSession,
              !item.baseItem.isLiveStream,
              item.baseItem.type == .episode,
              mediaSession.queue != nil
        else { return nil }

        self.item = item
        self.store = item.overlayActions

        mediaSession.playbackEvents
            .sink { [weak self] event in
                switch event {
                case .positionChanged, .seekCompleted:
                    self?.update()
                case .seekRequested:
                    self?.withdraw()
                }
            }
            .store(in: &observations)
    }

    isolated deinit {
        withdraw()
    }

    private func update() {
        guard let item,
              let session = item.mediaSession,
              session.playbackItem === item,
              session.state == .playback,
              !session.isSeeking,
              let duration = session.duration,
              duration > .zero
        else {
            withdraw()
            return
        }

        let remaining = duration - session.seconds

        guard remaining <= Self.leadTime,
              remaining > .zero,
              !isDismissed,
              let next = session.queue?.nextItem
        else {
            withdraw()
            return
        }
        guard publishedID == nil else { return }

        let id = UUID()
        publishedID = id

        store.publish(
            .init(
                id: id,
                action: { [weak self, weak session] in
                    self?.isDismissed = true
                    self?.withdraw()
                    _ = session?.playNewItem(intent: next)
                },
                onDismiss: { [weak self] in
                    self?.isDismissed = true
                    self?.publishedID = nil
                }
            ) {
                UpNextCardLabel(item: next.item)
            }
        )
    }

    private func withdraw() {
        guard let publishedID else { return }

        self.publishedID = nil
        store.withdraw(publishedID)
    }
}

/// The label inside the overlay action capsule: episode thumbnail, "UP NEXT", and the episode name.
struct UpNextCardLabel: View {

    @AdaptiveLayout
    private var viewLayout

    let item: BaseItemDto

    private var thumbnailHeight: CGFloat {
        viewLayout.value(standard: 40, large: 60)
    }

    private var subtitle: String {
        [item.seasonEpisodeLabel, item.displayTitle]
            .compactMap(\.self)
            .joined(separator: "  ·  ")
    }

    @ContentBuilder
    var body: some View {
        HStack(spacing: viewLayout.value(standard: 10, large: 16)) {
            ImageView(item.imageSources(for: .landscape, environment: .init(maxWidth: 320)))
                .placeholder { _ in
                    Color.helixSurface
                }
                .failure {
                    Color.helixSurface
                }
                .aspectRatio(16 / 9, contentMode: .fill)
                .frame(width: thumbnailHeight * 16 / 9, height: thumbnailHeight)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text("UP NEXT")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .tracking(1.5)
                    .opacity(0.7)

                Text(subtitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }

            Image(systemName: "play.fill")
                .font(.headline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Up next, \(subtitle)")
    }
}
