# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::FileUploadComponent, type: :component do
  describe "initialization" do
    it "initializes with name" do
      component = described_class.new(name: "document")

      expect(component).to be_a(described_class)
    end

    it "accepts accept parameter" do
      component = described_class.new(name: "document", accept: ".pdf,.doc")

      expect(component.instance_variable_get(:@accept)).to eq(".pdf,.doc")
    end

    it "accepts multiple parameter" do
      component = described_class.new(name: "documents[]", multiple: true)

      expect(component.instance_variable_get(:@multiple)).to eq(true)
    end

    it "accepts max_size parameter" do
      component = described_class.new(name: "document", max_size: 50.megabytes)

      expect(component.instance_variable_get(:@max_size)).to eq(50.megabytes)
    end

    it "accepts max_files parameter" do
      component = described_class.new(name: "documents[]", max_files: 5)

      expect(component.instance_variable_get(:@max_files)).to eq(5)
    end

    it "accepts preview parameter" do
      component = described_class.new(name: "photo", preview: false)

      expect(component.instance_variable_get(:@preview)).to eq(false)
    end

    it "accepts drop_text parameter" do
      component = described_class.new(name: "document", drop_text: "Drag files here")

      expect(component.instance_variable_get(:@drop_text)).to eq("Drag files here")
    end

    it "accepts browse_text parameter" do
      component = described_class.new(name: "document", browse_text: "click to browse")

      expect(component.instance_variable_get(:@browse_text)).to eq("click to browse")
    end

    it "defaults multiple to false" do
      component = described_class.new(name: "document")

      expect(component.instance_variable_get(:@multiple)).to eq(false)
    end

    it "defaults max_size to 10MB" do
      component = described_class.new(name: "document")

      expect(component.instance_variable_get(:@max_size)).to eq(10 * 1024 * 1024)
    end

    it "defaults max_files to 10" do
      component = described_class.new(name: "document")

      expect(component.instance_variable_get(:@max_files)).to eq(10)
    end

    it "defaults preview to true" do
      component = described_class.new(name: "document")

      expect(component.instance_variable_get(:@preview)).to eq(true)
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders wrapper div with form-field class" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css("div.form-field")
      end

      it "renders Stimulus controller container" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-controller="components--file-upload"]')
      end

      it "renders file input element" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('input[type="file"][name="document"]', visible: :all)
      end

      it "renders file input with generated id" do
        render_inline(described_class.new(name: "user[document]"))

        expect(page).to have_css('input[type="file"]#user_document', visible: :all)
      end

      it "renders label when provided" do
        render_inline(described_class.new(name: "document", label: "Upload Document"))

        expect(page).to have_css('label[for="document"]', text: "Upload Document")
      end

      it "renders hint when provided" do
        render_inline(described_class.new(name: "document", hint: "PDF files only"))

        expect(page).to have_css('p#document-hint', text: "PDF files only")
      end

      it "renders error when provided" do
        render_inline(described_class.new(name: "document", error: "is required"))

        expect(page).to have_css('p#document-error[role="alert"]', text: "is required")
      end

      it "renders error instead of hint when both present" do
        render_inline(described_class.new(name: "document", hint: "Help", error: "Invalid"))

        expect(page).to have_css('p#document-error')
        expect(page).not_to have_css('p#document-hint')
      end
    end

    context "with drop zone" do
      it "renders drop zone container" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-components--file-upload-target="dropZone"]')
      end

      it "renders drop zone with dashed border" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css("div.border-dashed.border-2")
      end

      it "renders drop zone with button role" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[role="button"]')
      end

      it "renders drop zone with accessible aria-label" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[aria-label="Zone de dépôt de fichier. Appuyez sur Entrée ou Espace pour parcourir les fichiers."]')
      end

      it "renders drop zone with tabindex for keyboard focus" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[role="button"][tabindex="0"]')
      end

      it "does not render tabindex when disabled" do
        render_inline(described_class.new(name: "document", disabled: true))

        expect(page).not_to have_css('[role="button"][tabindex="0"]')
      end

      it "renders default drop text for single file" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-components--file-upload-target="dropText"]', text: "Déposez un fichier ici ou")
      end

      it "renders default drop text for multiple files" do
        render_inline(described_class.new(name: "documents[]", multiple: true))

        expect(page).to have_css('[data-components--file-upload-target="dropText"]', text: "Déposez des fichiers ici ou")
      end

      it "renders custom drop text" do
        render_inline(described_class.new(name: "document", drop_text: "Drag your file here"))

        expect(page).to have_css('[data-components--file-upload-target="dropText"]', text: "Drag your file here")
      end

      it "renders browse button" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-components--file-upload-target="browseButton"]', text: "parcourir")
      end

      it "renders custom browse text" do
        render_inline(described_class.new(name: "document", browse_text: "select file"))

        expect(page).to have_css('[data-components--file-upload-target="browseButton"]', text: "select file")
      end

      it "renders drag overlay element" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-components--file-upload-target="dragOverlay"].hidden')
      end
    end

    context "with upload icon" do
      it "renders default upload icon" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-components--file-upload-target="iconContainer"]')
      end

      it "renders custom icon when provided" do
        render_inline(described_class.new(name: "document")) do |component|
          component.with_icon do
            "<svg>custom icon</svg>".html_safe
          end
        end

        expect(page).to have_content("custom icon")
      end
    end

    context "with file type restrictions" do
      it "renders accept attribute on input" do
        render_inline(described_class.new(name: "document", accept: ".pdf,.doc,.docx"))

        expect(page).to have_css('input[type="file"][accept=".pdf,.doc,.docx"]', visible: :all)
      end

      it "renders accepted types description" do
        render_inline(described_class.new(name: "document", accept: ".pdf,.doc"))

        expect(page).to have_css('[data-components--file-upload-target="restrictions"]', text: "PDF, DOC")
      end

      it "handles image/* mime type" do
        render_inline(described_class.new(name: "photo", accept: "image/*"))

        expect(page).to have_css('[data-components--file-upload-target="restrictions"]', text: "*")
      end
    end

    context "with multiple file support" do
      it "renders multiple attribute on input" do
        render_inline(described_class.new(name: "documents[]", multiple: true))

        expect(page).to have_css('input[type="file"][multiple]', visible: :all)
      end

      it "does not render multiple attribute when false" do
        render_inline(described_class.new(name: "document", multiple: false))

        expect(page).not_to have_css('input[type="file"][multiple]', visible: :all)
      end

      it "renders max files restriction" do
        render_inline(described_class.new(name: "documents[]", multiple: true, max_files: 5))

        expect(page).to have_css('[data-components--file-upload-target="restrictions"]', text: "Jusqu'à 5 fichiers")
      end
    end

    context "with file size restrictions" do
      it "renders max size in human readable format" do
        render_inline(described_class.new(name: "document", max_size: 5.megabytes))

        expect(page).to have_css('[data-components--file-upload-target="restrictions"]', text: "Max 5 MB")
      end

      it "handles kilobyte sizes" do
        render_inline(described_class.new(name: "document", max_size: 500.kilobytes))

        expect(page).to have_css('[data-components--file-upload-target="restrictions"]', text: "Max 500 KB")
      end
    end

    context "with required field" do
      it "renders required indicator in label" do
        render_inline(described_class.new(
          name: "document",
          label: "Document",
          required: true
        ))

        expect(page).to have_css('label span.text-red-500', text: "*")
      end

      it "includes required attribute on input" do
        render_inline(described_class.new(name: "document", required: true))

        expect(page).to have_css('input[type="file"][required]', visible: :all)
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on input" do
        render_inline(described_class.new(name: "document", disabled: true))

        expect(page).to have_css('input[type="file"][disabled]', visible: :all)
      end

      it "applies disabled styling to drop zone" do
        render_inline(described_class.new(name: "document", disabled: true))

        expect(page).to have_css('[data-components--file-upload-target="dropZone"].cursor-not-allowed')
      end

      it "disables browse button" do
        render_inline(described_class.new(name: "document", disabled: true))

        expect(page).to have_css('[data-components--file-upload-target="browseButton"][disabled]')
      end
    end

    context "with error state" do
      it "applies error styling to drop zone" do
        render_inline(described_class.new(name: "document", error: "Invalid"))

        expect(page).to have_css('[data-components--file-upload-target="dropZone"].border-red-300')
      end

      it "sets aria-invalid attribute" do
        render_inline(described_class.new(name: "document", error: "Invalid"))

        expect(page).to have_css('input[type="file"][aria-invalid="true"]', visible: :all)
      end

      it "sets aria-describedby to error id" do
        render_inline(described_class.new(name: "document", error: "Invalid"))

        expect(page).to have_css('input[type="file"][aria-describedby="document-error"]', visible: :all)
      end
    end

    context "with different sizes" do
      it "applies small size classes to drop zone" do
        render_inline(described_class.new(
          name: "document",
          label: "Document",
          size: :small
        ))

        expect(page).to have_css('[data-components--file-upload-target="dropZone"].p-4.min-h-24')
      end

      it "applies medium size classes to drop zone" do
        render_inline(described_class.new(
          name: "document",
          label: "Document",
          size: :medium
        ))

        expect(page).to have_css('[data-components--file-upload-target="dropZone"].p-6.min-h-32')
      end

      it "applies large size classes to drop zone" do
        render_inline(described_class.new(
          name: "document",
          label: "Document",
          size: :large
        ))

        expect(page).to have_css('[data-components--file-upload-target="dropZone"].p-8.min-h-40')
      end

      it "applies small size text classes" do
        render_inline(described_class.new(name: "document", size: :small))

        expect(page).to have_css('[data-components--file-upload-target="textContainer"].text-xs')
      end

      it "applies medium size text classes" do
        render_inline(described_class.new(name: "document", size: :medium))

        expect(page).to have_css('[data-components--file-upload-target="textContainer"].text-sm')
      end

      it "applies large size text classes" do
        render_inline(described_class.new(name: "document", size: :large))

        expect(page).to have_css('[data-components--file-upload-target="textContainer"].text-base')
      end
    end

    context "with file list and templates" do
      it "renders hidden file list container" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-components--file-upload-target="fileList"].hidden')
      end

      it "renders file item template" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('template[data-components--file-upload-target="fileItemTemplate"]', visible: :all)
      end

      it "renders image preview template" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('template[data-components--file-upload-target="imagePreviewTemplate"]', visible: :all)
      end

      it "renders file icon template" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('template[data-components--file-upload-target="fileIconTemplate"]', visible: :all)
      end

      it "renders validation error element" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-components--file-upload-target="validationError"].hidden')
      end
    end

    context "with Stimulus integration" do
      it "includes max size value" do
        render_inline(described_class.new(name: "document", max_size: 5.megabytes))

        expect(page).to have_css("[data-components--file-upload-max-size-value=\"#{5.megabytes}\"]")
      end

      it "includes max files value" do
        render_inline(described_class.new(name: "documents[]", max_files: 3))

        expect(page).to have_css('[data-components--file-upload-max-files-value="3"]')
      end

      it "includes accept value" do
        render_inline(described_class.new(name: "document", accept: ".pdf"))

        expect(page).to have_css('[data-components--file-upload-accept-value=".pdf"]')
      end

      it "includes multiple value" do
        render_inline(described_class.new(name: "documents[]", multiple: true))

        expect(page).to have_css('[data-components--file-upload-multiple-value="true"]')
      end

      it "includes preview value" do
        render_inline(described_class.new(name: "photo", preview: true))

        expect(page).to have_css('[data-components--file-upload-preview-value="true"]')
      end

      it "includes drag and drop actions" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-action*="dragenter->components--file-upload#handleDragEnter"]')
        expect(page).to have_css('[data-action*="dragover->components--file-upload#handleDragOver"]')
        expect(page).to have_css('[data-action*="dragleave->components--file-upload#handleDragLeave"]')
        expect(page).to have_css('[data-action*="drop->components--file-upload#handleDrop"]')
      end

      it "includes click action on drop zone" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-action*="click->components--file-upload#handleDropZoneClick"]')
      end

      it "includes keydown action for accessibility" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('[data-action*="keydown->components--file-upload#handleKeydown"]')
      end

      it "includes file change action" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('input[data-action="change->components--file-upload#handleFileSelect"]', visible: :all)
      end

      it "includes input target" do
        render_inline(described_class.new(name: "document"))

        expect(page).to have_css('input[data-components--file-upload-target="input"]', visible: :all)
      end
    end
  end

  describe "accessibility" do
    it "uses semantic label element" do
      render_inline(described_class.new(name: "document", label: "Document"))

      expect(page).to have_css("label")
    end

    it "associates label with input via for attribute" do
      render_inline(described_class.new(
        name: "document",
        id: "user_document",
        label: "Document"
      ))

      expect(page).to have_css('label[for="user_document"]')
      expect(page).to have_css('input#user_document', visible: :all)
    end

    it "hides file input visually but keeps it accessible" do
      render_inline(described_class.new(name: "document"))

      expect(page).to have_css('input.sr-only[type="file"]', visible: :all)
    end

    it "includes aria-describedby for hint" do
      render_inline(described_class.new(name: "document", hint: "Help"))

      expect(page).to have_css('input[aria-describedby="document-hint"]', visible: :all)
    end

    it "includes aria-describedby for error" do
      render_inline(described_class.new(name: "document", error: "Invalid"))

      expect(page).to have_css('input[aria-describedby="document-error"]', visible: :all)
    end

    it "error has role=alert" do
      render_inline(described_class.new(name: "document", error: "Invalid"))

      expect(page).to have_css('p[role="alert"]')
    end

    it "renders drop zone as accessible button" do
      render_inline(described_class.new(name: "document"))

      expect(page).to have_css('[role="button"][aria-label]')
    end
  end

  describe "edge cases" do
    it "handles nil accept value" do
      render_inline(described_class.new(name: "document", accept: nil))

      expect(page).to have_css('input[type="file"]', visible: :all)
      expect(page).not_to have_css('input[accept]', visible: :all)
    end

    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[profile][avatar]",
        label: "Avatar"
      ))

      expect(page).to have_css('input[name="user[profile][avatar]"]', visible: :all)
      expect(page).to have_css('input#user_profile_avatar', visible: :all)
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[documents][]",
        accept: ".pdf,.doc",
        multiple: true,
        max_size: 25.megabytes,
        max_files: 3,
        label: "Documents",
        hint: "Upload your documents",
        error: "at least one required",
        required: true,
        size: :large
      ))

      expect(page).to have_css('input[name="user[documents][]"]', visible: :all)
      expect(page).to have_css('input[multiple]', visible: :all)
      expect(page).to have_css('input[accept=".pdf,.doc"]', visible: :all)
      expect(page).to have_css("label", text: "Documents")
      expect(page).to have_css("label span", text: "*")
      expect(page).to have_css('p[role="alert"]', text: "at least one required")
      expect(page).to have_content("Max 25 MB")
      expect(page).to have_content("Jusqu'à 3 fichiers")
    end

    it "combines multiple file type descriptions" do
      render_inline(described_class.new(
        name: "document",
        accept: ".pdf,.doc,.xlsx,image/*",
        max_size: 10.megabytes
      ))

      expect(page).to have_content("PDF")
      expect(page).to have_content("DOC")
      expect(page).to have_content("XLSX")
    end
  end

  describe "#multiple?" do
    it "returns true when multiple is set" do
      component = described_class.new(name: "docs[]", multiple: true)

      expect(component.multiple?).to eq(true)
    end

    it "returns false when multiple is not set" do
      component = described_class.new(name: "doc")

      expect(component.multiple?).to eq(false)
    end
  end

  describe "#preview?" do
    it "returns true when preview is enabled" do
      component = described_class.new(name: "photo", preview: true)

      expect(component.preview?).to eq(true)
    end

    it "returns false when preview is disabled" do
      component = described_class.new(name: "doc", preview: false)

      expect(component.preview?).to eq(false)
    end
  end

  describe "#drop_zone_text" do
    it "returns custom text when provided" do
      component = described_class.new(name: "doc", drop_text: "Drag here")

      expect(component.drop_zone_text).to eq("Drag here")
    end

    it "returns singular text for single file upload" do
      component = described_class.new(name: "doc", multiple: false)

      expect(component.drop_zone_text).to eq("Déposez un fichier ici ou")
    end

    it "returns plural text for multiple file upload" do
      component = described_class.new(name: "docs[]", multiple: true)

      expect(component.drop_zone_text).to eq("Déposez des fichiers ici ou")
    end
  end

  describe "#browse_button_text" do
    it "returns custom text when provided" do
      component = described_class.new(name: "doc", browse_text: "click here")

      expect(component.browse_button_text).to eq("click here")
    end

    it "returns default text when not provided" do
      component = described_class.new(name: "doc")

      expect(component.browse_button_text).to eq("parcourir")
    end
  end

  describe "#human_max_size" do
    it "returns human readable file size" do
      component = described_class.new(name: "doc", max_size: 5.megabytes)

      expect(component.human_max_size).to eq("5 MB")
    end

    it "handles kilobyte sizes" do
      component = described_class.new(name: "doc", max_size: 500.kilobytes)

      expect(component.human_max_size).to eq("500 KB")
    end
  end

  describe "#accepted_types_description" do
    it "returns nil when no accept specified" do
      component = described_class.new(name: "doc", accept: nil)

      expect(component.accepted_types_description).to be_nil
    end

    it "returns nil when accept is blank" do
      component = described_class.new(name: "doc", accept: "")

      expect(component.accepted_types_description).to be_nil
    end

    it "formats file extensions" do
      component = described_class.new(name: "doc", accept: ".pdf,.doc,.xlsx")

      expect(component.accepted_types_description).to eq("PDF, DOC, XLSX")
    end

    it "formats mime types" do
      component = described_class.new(name: "photo", accept: "image/png,image/jpeg")

      expect(component.accepted_types_description).to eq("PNG, JPEG")
    end

    it "handles wildcard mime types" do
      component = described_class.new(name: "photo", accept: "image/*")

      expect(component.accepted_types_description).to eq("*")
    end

    it "removes duplicates" do
      component = described_class.new(name: "doc", accept: ".pdf,.PDF")

      expect(component.accepted_types_description).to eq("PDF")
    end
  end
end
