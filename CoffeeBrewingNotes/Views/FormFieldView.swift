import SwiftUI

/// Reusable form field component with consistent styling
struct FormFieldView: View {
    let title: String
    let value: String
    let unit: String?
    
    init(_ title: String, value: String, unit: String? = nil) {
        self.title = title
        self.value = value
        self.unit = unit
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Group {
                Text(value)
                if let unit = unit {
                    Text(unit)
                        .foregroundColor(.secondary)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}

/// Reusable recipe parameter row view
struct RecipeParameterRowView: View {
    let parameter: String
    let value: String
    
    var body: some View {
        HStack {
            Text(parameter)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

/// Reusable section with optional badge
struct FormSectionView<Content: View>: View {
    let title: String
    let badge: String?
    let content: Content
    
    init(_ title: String, badge: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.badge = badge
        self.content = content()
    }
    
    var body: some View {
        Section(header: sectionHeader) {
            content
        }
    }
    
    @ViewBuilder
    private var sectionHeader: some View {
        HStack {
            Text(title)
            if let badge = badge {
                Spacer()
                Text(badge)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
        }
    }
}

/// Reusable measurement input field
struct MeasurementFieldView: View {
    let title: String
    let value: Binding<String>
    let unit: String
    let keyboardType: UIKeyboardType
    
    init(_ title: String, value: Binding<String>, unit: String, keyboardType: UIKeyboardType = .numberPad) {
        self.title = title
        self.value = value
        self.unit = unit
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: value)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// Reusable numeric stepper field
struct StepperFieldView: View {
    let title: String
    let value: Binding<Int>
    let unit: String
    let range: ClosedRange<Int>
    let step: Int
    
    init(_ title: String, value: Binding<Int>, unit: String, range: ClosedRange<Int>, step: Int = 1) {
        self.title = title
        self.value = value
        self.unit = unit
        self.range = range
        self.step = step
    }
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Stepper(
                value: value,
                in: range,
                step: step
            ) {
                HStack(spacing: 4) {
                    Text("\(value.wrappedValue)")
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview("Form Fields") {
    Form {
        Section("Recipe Details") {
            FormFieldView("Brewing Method", value: "V60-01")
            FormFieldView("Water Temperature", value: "93", unit: "°C")
            FormFieldView("Dose", value: "20.0", unit: "g")
        }
        
        Section("Parameters") {
            RecipeParameterRowView(parameter: "Grind Size", value: "18")
            RecipeParameterRowView(parameter: "Brew Time", value: "240s")
        }
        
        Section("Input Fields") {
            MeasurementFieldView("Dose", value: .constant("20"), unit: "g")
            StepperFieldView("Temperature", value: .constant(93), unit: "°C", range: 80...100)
        }
    }
}

#Preview("Form Section") {
    Form {
        FormSectionView("Recipe List", badge: "12 recipes") {
            Text("Recipe 1")
            Text("Recipe 2")
        }
    }
}