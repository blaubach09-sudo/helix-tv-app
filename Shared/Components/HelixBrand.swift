//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import CoreText
import SwiftUI
import UIKit

enum HelixBrand {

    static let wordmarkFontName = "Michroma"

    /// Registers bundled brand fonts once. Safe to call repeatedly.
    static func registerFonts() {
        guard !isRegistered else { return }

        isRegistered = true
        guard let asset = NSDataAsset(name: "Michroma"),
              let provider = CGDataProvider(data: asset.data as CFData),
              let font = CGFont(provider)
        else {
            assertionFailure("Michroma data asset missing")
            return
        }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }

    private static var isRegistered = false
}

/// "HELIX" in white, "TV" in gold, Michroma, wide tracking, soft gold glow — same as the web skin.
struct HelixWordmark: View {

    var size: CGFloat = 24

    @ContentBuilder
    var body: some View {
        HStack(spacing: 0) {
            Text("HELIX")
                .foregroundStyle(.white)
            Text("TV")
                .foregroundStyle(Color.helixGold)
        }
        .font(.custom(HelixBrand.wordmarkFontName, size: size))
        .tracking(size * 0.32)
        .shadow(color: Color.helixGold.opacity(0.45), radius: size * 0.4)
        .accessibilityLabel("Helix TV")
    }
}

/// Mark + wordmark lockup used in toolbars (connect screen, user picker).
struct HelixLockup: View {

    var height: CGFloat = 36

    @ContentBuilder
    var body: some View {
        HStack(spacing: height * 0.45) {
            Image(.helixMark)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: height)
            HelixWordmark(size: height * 0.55)
        }
    }
}
