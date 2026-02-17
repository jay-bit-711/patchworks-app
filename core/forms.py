# core/forms.py
from django import forms
from .models import Evidence

class EvidenceAdminForm(forms.ModelForm):
    content_type = forms.CharField(widget=forms.HiddenInput(), required=False)

    class Meta:
        model = Evidence
        fields = '__all__'

    def clean_file(self):
        file = self.cleaned_data.get('file')
        if file:
            if file.size > 50 * 1024 * 1024:
                raise forms.ValidationError("File size exceeds 50MB limit.")
            # Store content_type for model save
            self.instance._temp_content_type = file.content_type
        return file