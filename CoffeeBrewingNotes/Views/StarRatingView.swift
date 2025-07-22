import SwiftUI

/// Reusable star rating component that can display and edit ratings
struct StarRatingView: View {
    @Binding var rating: Int
    let isInteractive: Bool
    let starSize: Font
    let fillColor: Color
    let emptyColor: Color
    
    init(
        rating: Binding<Int>,
        isInteractive: Bool = true,
        starSize: Font = .title2,
        fillColor: Color = .yellow,
        emptyColor: Color = .gray
    ) {
        self._rating = rating
        self.isInteractive = isInteractive
        self.starSize = starSize
        self.fillColor = fillColor
        self.emptyColor = emptyColor
    }
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(1...5, id: \.self) { star in
                if isInteractive {
                    Button(action: {
                        // If tapping the same star that's already selected, clear the rating
                        if rating == star {
                            rating = 0
                        } else {
                            rating = star
                        }
                    }) {
                        starImage(for: star)
                    }
                } else {
                    starImage(for: star)
                }
            }
            
            if isInteractive && rating > 0 {
                Button("Clear") {
                    rating = 0
                }
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.leading, 8)
            }
        }
    }
    
    @ViewBuilder
    private func starImage(for star: Int) -> some View {
        Image(systemName: star <= rating ? "star.fill" : "star")
            .foregroundColor(star <= rating ? fillColor : emptyColor)
            .font(starSize)
    }
}

/// Display-only star rating view for consistent rating display
struct StarRatingDisplayView: View {
    let rating: Int16
    let starSize: Font
    let fillColor: Color
    let emptyColor: Color
    
    init(
        rating: Int16,
        starSize: Font = .caption,
        fillColor: Color = .yellow,
        emptyColor: Color = .gray
    ) {
        self.rating = rating
        self.starSize = starSize
        self.fillColor = fillColor
        self.emptyColor = emptyColor
    }
    
    var body: some View {
        if rating > 0 {
            HStack(spacing: 1) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundColor(star <= rating ? fillColor : emptyColor)
                        .font(starSize)
                }
            }
        } else {
            Text("No rating")
                .font(starSize)
                .foregroundColor(.secondary)
        }
    }
}

/// Star rating display for filter options
struct StarRatingFilterView: View {
    let rating: Int
    let isSelected: Bool
    
    var body: some View {
        HStack {
            if rating == 0 {
                Text("All Ratings")
            } else {
                Text("\(rating) Star\(rating > 1 ? "s" : "")")
            }
            
            Spacer()
            
            if rating > 0 {
                HStack(spacing: 1) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundColor(star <= rating ? .yellow : .gray)
                            .font(.caption)
                    }
                }
            }
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview("Interactive Rating") {
    @State var rating = 3
    return VStack(spacing: 20) {
        StarRatingView(rating: $rating)
        Text("Current rating: \(rating)")
    }
    .padding()
}

#Preview("Display Only") {
    VStack(spacing: 10) {
        StarRatingDisplayView(rating: 4)
        StarRatingDisplayView(rating: 0)
        StarRatingDisplayView(rating: 2, starSize: .title, fillColor: .orange)
    }
    .padding()
}

#Preview("Filter Options") {
    VStack {
        StarRatingFilterView(rating: 0, isSelected: false)
        StarRatingFilterView(rating: 3, isSelected: true)
        StarRatingFilterView(rating: 5, isSelected: false)
    }
    .padding()
}