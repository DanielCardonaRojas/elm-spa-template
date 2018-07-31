import flatpickr from 'flatpickr';


class Flatpickr extends HTMLElement {

    constructor(){
        super();
        this.addEventListener("input", function(e){
            this.innerText = e.target.value
        });

        this.addEventListener("blur", function(e){
            //console.log("onBlur");
            //console.log(e);
        });

        this.addEventListener("focusout", function(e){
            //console.log("onFocusOut");
            //console.log(e);
        });

        this._placeholder = '';
    }

    static get observedAttributes() {
        return [
            'value', 'val', 'mode', 'enable-time', 
            'date-format', 'week-numbers', 'placeholder',
            'disabled'
        ];
    }

    // Configuration Attributes
    get placeholder() {
        return this._placeholder;
    }
    get dateFormat() {
        const val = this.getAttribute('dateFormat') || "Y-m-d H:i";
        return val
    }

    get isMilitaryTime() {
        return this.getAttribute('time-24hr') == 'true' || false;
    }

    get minDate() {
        return this.getAttribute('min-date') || null;
    }

    get maxDate() {
        return this.getAttribute('max-date') || null;
    }

    get enableTime() {
        return this.getAttribute('enable-time') == 'true' || false
    }

    get enableSeconds() {
        return this.getAttribute('enable-seconds') == 'true' || false
    }

    get minuteIncrement() {
        const val = this.getAttribute('minute-increment');
        return parseInt(val) || 5
    }

    get mode() { //single, page, multipage
        return this.getAttribute('mode') || 'single';
    }

    get weekNumbers() {
        return this.getAttribute('week-numbers') == 'true' || false
    }

    set val(v) {
        if (this._flatpickr) {
            const format = this._flatpickr.config.dateFormat;
            const date = this._flatpickr.parseDate(v, format);
            this._flatpickr.setDate(date, false, format);
            this.innerText = v;
        } else {
            this.innerText = v;
        }
    }

    set placeholder(v) {
        this._placeholder = v;
    }

    // Life Cycle
    attributeChangedCallback(name, oldVal, newVal) {
        console.log("Changed: " + name + " old: " + oldVal + " new: " + newVal);
        const camelName = this.snakeToCamel(name);
        if (this._flatpickr) { 
            if (camelName in this._flatpickr.config){
                this._flatpickr.set(camelName, newVal); 
                this._flatpickr.redraw();
            }
        }
        if (name == 'val') {
            this.val = newVal
        }
    }

    connectedCallback() {
        var self = this;
        //const defaultText = this.getAttribute('val') || '';
        //this.innerText = defaultText;

        flatpickr(self, {
            dateFormat: self.dateFormat,
            minDate: self.minDate,
            maxDate: self.maxDate,
            enableTime: self.enableTime,
            enableSeconds: self.enableSeconds,
            minuteIncrement: self.minuteIncrement,
            mode: self.mode,
            weekNumbers: self.weekNumbers,
            onChange: function(e) {

                console.log("flatpickr onChange");
                console.log(e);
                this.open();
            }
        });

    }

    disconnectedCallback() {
    }

    // Helper functions
    snakeToCamel(s){
        return s.replace(/(\-\w)/g, function(m){return m[1].toUpperCase();
    });
}
}

customElements.define('flat-pickr', Flatpickr);
