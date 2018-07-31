//import Dropzone from "../../node_modules/dropzone/dist/min/dropzone.min.js";
import Dropzone from "dropzone"

class DropzoneUpload extends HTMLElement {
    constructor(){
        super();
        this._method = 'POST';
        this._dictDefaultMessage = 'Drop files here!';
    }

    // Attributes
    get url() {
        return this.getAttribute('url');
    }

    get method() {
        return this._method;
    }

    set method(http_verb) {
        this.setAttribute('method', http_verb);
    }

    get defaultmessage() {
        return this.getAttribute('default-message');
    }

    get uploadMultiple() {
        return this.getAttribute('upload-multiple') == 'true'; 
    }

    get parallelUploads() {
        const num = this.getAttribute('parallel-uploads'); 
        return parseInt(num) || 2 
    }

    get autoProcessQueue() {
        if (this.hasAttribute('auto-process-queue')) {
            return this.getAttribute('auto-process-queue') == 'true';
        }
        return false;
    }

    get maxFiles() {
        const num = this.getAttribute('max-files'); 
        return parseInt(num) || 1 
    }

    get upload() {
        return this.hasAttribute('process');
    }

    get removeLinks() {
        return this.getAttribute('add-remove-links') == 'true' || false
    }

    static get observedAttributes() {
        return [ 'method', 'url', 'upload' ];
    }

    // Life Cycle
    attributeChangedCallback(name, oldVal, newVal) {
        //console.log("Changed: " + name + " old: " + oldVal + " new: " + newVal);

        if (name == 'upload' && this.upload) {
            this._dropzone.processQueue();
            return
        }

        if (!this._dropzone) { return };
        if (name in this._dropzone.options) {
            this._dropzone.options[name] = newVal;
        }
    }

    connectedCallback() {
        const shadowRoot = this.attachShadow({mode: 'closed'});
        shadowRoot.appendChild(this.template.content.cloneNode(true));
        const elem = shadowRoot.getElementById('dropfile');

        var self = this;

        this._dropzone = new Dropzone(elem, { 
            url: self.url,
            maxFileSize: 2,
            dictDefaultMessage: self.defaultmessage,
            autoProcessQueue: self.autoProcessQueue,
            uploadMultiple: self.uploadMultiple,
            maxFiles: self.maxFiles,
            addRemoveLinks: self.removeLinks,
            acceptedFiles: "image/*"
        });

        const fileProperties = function(file) {
            return {
            'name': file.name,
            'size': file.size,
            'status': file.status,
            'type': file.type
            }
        };

        this._dropzone.on("addedfile", function(file) { 
            const customEvent = new CustomEvent('addedfile', {
                bubbles: true, 
                composed: true,
                detail: { 'file': fileProperties(file)}
            });
            self.dispatchEvent(customEvent);
        }); 

        this._dropzone.on("dragover", function(e){
            const customEvent = new CustomEvent('dragover', {
                bubbles: true, 
                composed: true,
                detail: e
            });
            self.dispatchEvent(customEvent);
        });

        this._dropzone.on("dragleave", function(e){
            const customEvent = new CustomEvent('dragleave', {
                bubbles: true, 
                composed: true,
                detail: e
            });
            self.dispatchEvent(customEvent);
        });

        this._dropzone.on("dragenter", function(e){
            const customEvent = new CustomEvent('dragenter', {
                bubbles: true, 
                composed: true,
                detail: e
            });
            self.dispatchEvent(customEvent);
        });


    }


    get template() {
        if (this._template) {return this._template;}

        this._template = document.createElement('template');
        let styles = document.createElement('style');
        let content = document.createElement('div');
        let imports = document.createElement('head');

        imports.innerHTML = `
        <link rel="stylesheet" href="../../../node_modules/dropzone/dist/dropzone.css">
        <link rel="stylesheet" type="text/css" href="../webcomponents/DropzoneUpload/Dropzone.css">
        `;
        content.id = 'dropfile';
        content.className = 'dropzone';

        styles.innerHTML = `
        `;

        content.innerHTML = `
        `;


        this._template.content.appendChild(styles);
        this._template.content.appendChild(imports);
        this._template.content.appendChild(content);
        return this._template;
    }
}

customElements.define('drop-zone', DropzoneUpload);
