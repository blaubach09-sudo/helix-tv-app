//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import Defaults
import JellyfinAPI
import SwiftUI

// TODO: enabled/disabled state
// TODO: scrubbing snapping behaviors
//       - chapter boundaries
//       - current running time
// TODO: show chapter title under preview image
//       - have max width, on separate offset track

extension VideoPlayer.PlaybackControls {

    struct PlaybackProgress: View {

        @Default(.VideoPlayer.Overlay.chapterSlider)
        private var chapterSlider

        @Environment(ViewState.self)
        private var viewState
        @Environment(MediaSession.self)
        private var mediaSession
        @State
        private var sliderSize: CGSize = .zero

        @Toaster
        private var toaster: ToastProxy

        private let previewImageHeight: CGFloat = 200

        private var sliderHeight: CGFloat {
            // Helix TV: slim track, grows while scrubbing
            isScrubbing ? 16 : 10
        }

        // MARK: - Helix playhead + trail

        private let trailLength: CGFloat = 180

        private var playheadSize: CGFloat {
            isScrubbing ? 60 : 42
        }

        private var playheadX: CGFloat {
            guard sliderSize.width.isFinite, sliderSize.width > 0 else { return 0 }

            return sliderSize.width * scrubbedProgress
        }

        /// A soft, brighter gold glow that fades in behind the playhead along the played segment.
        @ContentBuilder
        private var helixTrail: some View {
            let width = min(trailLength, max(0, playheadX))
            LinearGradient(
                colors: [.clear, Color.white.opacity(0.65)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width, height: sliderHeight)
            .offset(x: max(0, playheadX - width))
            .blendMode(.plusLighter)
            .clipShape(Capsule())
            .allowsHitTesting(false)
        }

        /// The Helix mark rides the track, centred on it like a native playhead.
        @ContentBuilder
        private var helixPlayhead: some View {
            HelixPlayhead(size: playheadSize, isActive: isScrubbing)
                .offset(x: playheadX - playheadSize / 2)
                .allowsHitTesting(false)
        }

        private var isScrubbing: Bool {
            viewState.isScrubbing
        }

        private var scrubbedProgress: Double {
            guard let runtime = mediaSession.item.runtime, runtime > .zero else { return 0 }

            let progress = viewState.scrubbedSeconds / runtime
            guard progress.isFinite else { return 0 }

            return clamp(progress, min: 0, max: 1)
        }

        private var currentProgress: Double? {
            guard isScrubbing,
                  let runtime = mediaSession.item.runtime,
                  runtime > .zero
            else {
                return nil
            }

            let currentSeconds = viewState.scrubOriginSeconds ?? viewState.playbackSeconds
            let progress = (currentSeconds / runtime) * 100
            guard progress.isFinite else { return nil }

            return clamp(progress, min: 0, max: 100)
        }

        private var videoSizeAspectRatio: CGFloat {
            guard let aspectRatio = (mediaSession.player as? any VideoMediaPlayer)?
                .videoState
                .videoSize
                .aspectRatio
            else {
                return 1.77
            }

            return clamp(aspectRatio, min: 0.25, max: 4)
        }

        private var previewXOffset: CGFloat {
            guard sliderSize.width.isFinite, sliderSize.width > 0 else { return 0 }

            let videoWidth = previewImageHeight * videoSizeAspectRatio
            let p = (sliderSize.width * scrubbedProgress) - (videoWidth / 2)

            return clamp(p, min: 0, max: max(0, sliderSize.width - videoWidth))
        }

        @ContentBuilder
        private var liveIndicator: some View {
            Text(L10n.live)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(Color.gray)
                }
        }

        @ContentBuilder
        private var videoPlayerSlider: some View {
            SliderContainer(
                value: Bindable(viewState).scrubbedSeconds.map(
                    getter: {
                        guard let runtime = mediaSession.item.runtime, runtime > .zero else { return 0 }

                        let seconds = $0.seconds
                        let runtimeSeconds = runtime.seconds
                        guard seconds.isFinite, runtimeSeconds.isFinite, runtimeSeconds > 0 else { return 0 }

                        return clamp((seconds / runtimeSeconds) * 100, min: 0, max: 100)
                    },
                    setter: {
                        guard $0.isFinite else { return .zero }

                        return (mediaSession.item.runtime ?? .zero) * (clamp($0, min: 0, max: 100) / 100)
                    }
                ),
                total: 100,
                isScrollingEnabled: mediaSession.playbackRequestStatus == .paused && mediaSession.canSeek,
                originProgress: currentProgress
            )
            .onEditingChanged { isEditing in
                if isEditing {
                    viewState.beginScrub()
                }
            }
            .sliderContainerStyle(.capsule(showsProgressWhenUnfocused: true))
            .if(chapterSlider) { view in
                if let chapters = mediaSession.item.chapters, chapters.isNotEmpty {
                    view.inverseMask { ChapterTrackMask(chapters: chapters, runtime: mediaSession.item.runtime ?? .zero) }
                } else {
                    view
                }
            }
            .frame(height: sliderHeight)
            .trackingSize($sliderSize)
            .foregroundStyle(mediaSession.canSeek ? Color.helixGold : Color.gray)
            .overlay(alignment: .leading) {
                helixTrail
            }
            .overlay(alignment: .leading) {
                helixPlayhead
            }
            .disabled(!mediaSession.canSeek)
        }

        @ContentBuilder
        private var previewImage: some View {
            if isScrubbing, let previewImageProvider = mediaSession.playbackItem?.previewImageProvider {
                PreviewImageView(previewImageProvider: previewImageProvider)
                    .aspectRatio(videoSizeAspectRatio, contentMode: .fit)
                    .frame(height: previewImageHeight)
                    .posterBorder()
                    .cornerRadius(ratio: 1 / 30, of: \.width)
                    .offset(x: previewXOffset, y: -(previewImageHeight + 10))
                    .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 4)
            }
        }

        @ContentBuilder
        var body: some View {
            VStack(spacing: 18) {
                if mediaSession.item.isLiveStream {
                    liveIndicator
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    videoPlayerSlider

                    SplitTimeStamp()
                        .foregroundStyle(.white, Color.lightGray)
                }
            }
            .coordinatedFocus(ViewState.Focus.progress)
            .foregroundStyle(Color.white.opacity(0.75))
            .overlay(alignment: .topLeading) {
                previewImage
            }
        }
    }
}
