//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import SwiftUI

/// Helix TV: the DNA/film-strip mark used as the scrubber playhead.
///
/// Rests as a small pin on the track; while scrubbing it grows and slowly
/// twists about its vertical axis. Honors Reduce Motion (no twist).
struct HelixPlayhead: View {

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @State
    private var spin: Double = 0

    let size: CGFloat
    let isActive: Bool

    @ContentBuilder
    var body: some View {
        Image("helix-mark-vector")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .rotation3DEffect(.degrees(spin), axis: (x: 0, y: 1, z: 0))
            .shadow(color: Color.helixGold.opacity(isActive ? 0.9 : 0.55), radius: isActive ? 16 : 8)
            .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
            .animation(.spring(duration: 0.25), value: size)
            .onChange(of: isActive, initial: true) { _, active in
                guard !reduceMotion else {
                    spin = 0
                    return
                }

                if active {
                    withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                        spin = 360
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.4)) {
                        spin = 0
                    }
                }
            }
            .accessibilityHidden(true)
    }
}
