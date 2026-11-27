//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import MPVUI
import SwiftUI

struct MPVVideoPlayerView: View {

    @Environment(\.scenePhase)
    private var scenePhase

    /// Helix TV: lift captions above the transport bar while it is showing, like the native player.
    @Environment(VideoPlayer.ViewState.self)
    private var viewState: VideoPlayer.ViewState?

    let player: MPVPlayer
    let textSubtitles: TextSubtitlePresentation
    let layout: VideoPlayer.VideoLayout
    let isPictureInPictureActive: Bool

    private var videoSurface: MPVVideoPlayer {
        var surface = MPVVideoPlayer(player: player)

        if isPictureInPictureActive, player.videoFeatureCapabilities.pictureInPictureSubtitles.availability == .available {
            surface = surface.videoOverlay {
                PictureInPictureSubtitleOverlay(presentation: textSubtitles)
            }
        }

        return surface
    }

    private var captionsAreVisible: Bool {
        if isPictureInPictureActive {
            return player.pictureInPicture.isVideoOverlayActive && !player.pictureInPicture.isSuspended
        }

        return scenePhase == .active
    }

    private var captionBottomInset: CGFloat {
        guard !isPictureInPictureActive, let viewState else { return 0 }

        #if os(tvOS)
        let lift: CGFloat = 130
        #else
        let lift: CGFloat = 96 // phone transport bar: scrubber + timestamps + supplement tabs
        #endif

        switch viewState.presentation {
        case .progress, .controls:
            return lift
        case .hidden, .supplement:
            return 0
        }
    }

    @ContentBuilder
    var body: some View {
        videoSurface
            .frame(width: layout.renderSize.width, height: layout.renderSize.height)
            .scaleEffect(layout.renderScale)
            .offset(layout.renderOffset)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .overlay {
                if !isPictureInPictureActive, let snapshot = textSubtitles.snapshot {
                    TextSubtitleOverlay(snapshot: snapshot, videoLayout: layout, reportCaptions: nil)
                        .padding(.bottom, captionBottomInset)
                        .animation(.easeOut(duration: 0.2), value: captionBottomInset)
                }
            }
            .modifier(
                TextSubtitleReporting(
                    snapshot: textSubtitles.snapshot,
                    isVisible: captionsAreVisible
                )
            )
    }
}
