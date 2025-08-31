import SwiftUI
import SwiftData

struct PromptTemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var templates: [PromptTemplate] = []
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showingNewTemplate = false
    
    let categories = ["All", "Photography", "Art", "Sci-Fi", "Fantasy", "Design", "Vintage", "Architecture", "Custom"]
    
    var filteredTemplates: [PromptTemplate] {
        let categoryFiltered = selectedCategory == "All" ? templates : templates.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.prompt.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Callback to pass selected prompt to parent view
    let onTemplateSelected: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Theme.textSecondary)
                    TextField("Search templates...", text: $searchText)
                        .font(Theme.appFont(size: 16))
                }
                .padding()
                .background(Theme.secondaryColor)
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Category picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            Button(category) {
                                selectedCategory = category
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Theme.primaryColor : Theme.secondaryColor)
                            .foregroundColor(selectedCategory == category ? .white : Theme.textPrimary)
                            .cornerRadius(20)
                            .font(Theme.appFont(size: 14))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Templates list
                List {
                    ForEach(filteredTemplates) { template in
                        TemplateRow(template: template, onSelected: onTemplateSelected)
                    }
                    .onDelete(perform: deleteTemplates)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Prompt Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewTemplate = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Theme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingNewTemplate) {
                NewTemplateView { template in
                    modelContext.insert(template)
                    try? modelContext.save()
                    fetchTemplates()
                    showingNewTemplate = false
                }
            }
        }
        .onAppear {
            setupDefaultTemplates()
            fetchTemplates()
        }
    }
    
    private func fetchTemplates() {
        do {
            let descriptor = FetchDescriptor<PromptTemplate>(sortBy: [SortDescriptor(\.name)])
            templates = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching templates: \(error)")
        }
    }
    
    private func setupDefaultTemplates() {
        // Only add default templates if none exist
        let descriptor = FetchDescriptor<PromptTemplate>()
        do {
            let existingTemplates = try modelContext.fetch(descriptor)
            if existingTemplates.isEmpty {
                for template in PromptTemplate.defaultTemplates {
                    modelContext.insert(template)
                }
                try? modelContext.save()
            }
        } catch {
            print("Error setting up default templates: \(error)")
        }
    }
    
    private func deleteTemplates(offsets: IndexSet) {
        for index in offsets {
            let template = filteredTemplates[index]
            if template.isCustom { // Only allow deletion of custom templates
                modelContext.delete(template)
            }
        }
        try? modelContext.save()
        fetchTemplates()
    }
}

struct TemplateRow: View {
    let template: PromptTemplate
    let onSelected: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(template.name)
                        .font(Theme.appFont(size: 16, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(template.category)
                        .font(Theme.appFont(size: 12))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.primaryColor.opacity(0.2))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                Button("Use") {
                    onSelected(template.prompt)
                }
                .font(Theme.appFont(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Theme.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
            
            Text(template.prompt)
                .font(Theme.appFont(size: 14))
                .foregroundColor(Theme.textSecondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

struct NewTemplateView: View {
    @State private var name = ""
    @State private var prompt = ""
    @State private var selectedCategory = "Custom"
    
    let categories = ["Photography", "Art", "Sci-Fi", "Fantasy", "Design", "Vintage", "Architecture", "Custom"]
    let onSave: (PromptTemplate) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Template Details") {
                    TextField("Template Name", text: $name)
                        .font(Theme.appFont(size: 16))
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section("Prompt") {
                    TextEditor(text: $prompt)
                        .font(Theme.appFont(size: 14))
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Handle cancel
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let template = PromptTemplate(
                            name: name,
                            prompt: prompt,
                            category: selectedCategory,
                            isCustom: true
                        )
                        onSave(template)
                    }
                    .disabled(name.isEmpty || prompt.isEmpty)
                }
            }
        }
    }
}