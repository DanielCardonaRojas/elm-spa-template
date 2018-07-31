import GoogleMapsLoader from 'google-maps';

GoogleMapsLoader.KEY = 'AIzaSyBKDi6jysvIa7DtAIII4GfXLgGMGHNhUsY';
GoogleMapsLoader.LANGUAGE = 'es';
GoogleMapsLoader.LIBRARIES = ['geometry', 'places'];

class GoogleMap extends HTMLElement {
    constructor(){
        super();
        this._onMapClick = this._onMapClick.bind(this);
        this._onMapDragEnd = this._onMapDragEnd.bind(this);
        this._onMarkerDragEnd = this._onMarkerDragEnd.bind(this);
        this._onMarkerClick = this._onMarkerClick.bind(this);
        this.addMarkers = this.addMarkers.bind(this);
        this._markers = [];
        this._googleMarkers = [];
        this.google = null;
        this._map = null;
    }

    static get observedAttributes() {
        return ['latitude', 'longitude'];
    }

    // Marker property
    set markers(ms) {
        this._markers = ms;

        if (!(this.google && this._map)) {
            return
        }

        this.addMarkers(this._map, this.google); 
    }

    get markers() {
        return this._markers; 
    }

    //Configuration options

    get minZoom () {
        const val = this.getAttribute('max-zoom'); 
        return parseInt(val) || 0
    }
    
    get maxZoom () {
        const val = this.getAttribute('min-zoom'); 
        return parseInt(val) || 0
    }

    get streetViewControl() {
        return this.getAttribute('street-view-control') == 'true' || false
    }

    get fitToMarkers() {
        return this.hasAttribute('fit-to-markers');
    }

    get draggable() {
        return this.getAttribute('draggable') == 'true' || false 
    }

    get zoom() {
        const val = this.getAttribute('zoom');
        return parseInt(val) || 8
    }

    get zoomControl() {
        return this.getAttribute('zoom-control') == 'false' || true
    }

    get latitude() {
        const lat = parseFloat(this.getAttribute('latitude')) || 6.207775; 
        return lat
    }

    get longitude() {
        const lng = parseFloat(this.getAttribute('longitude')) || -75.563024; 
        return lng
    }
    get center() {
        const center = { lat: this.latitude, lng: this.longitude };
        return center
    }

    get mapType() {
        return this.getAttribute('map-type') || 'roadmap'; 
    }

    get apiKey() {
        return this.getAttribute('api-key');
    }

    // Life Cycle
    attributeChangedCallback(name, oldVal, newVal) {
        //console.log("Changed: " + name + " old: " + oldVal + " new: " + newVal);
        if (name == 'latitude' && oldVal != null) {
            const lat = parseFloat(newVal) || this._map.center.lat();
            const newCenter = {lat: lat, lng: this._map.center.lng()};
            this._map.setCenter(newCenter);
        } else if (name == 'longitude' && oldVal != null) {
            const lng = parseFloat(newVal) || this._map.center.lng();
            const newCenter = {lat: this._map.center.lat(), lng: lng};
            this._map.setCenter(newCenter);
        }
    }

    connectedCallback() {
        const shadowRoot = this.attachShadow({mode: 'open'});
        shadowRoot.appendChild(this.template.content.cloneNode(true));
        const elem = shadowRoot.getElementById('customMap');

        var self = this;

        GoogleMapsLoader.load(function(google) {
            self.google = google

            //const center = {lat: 6.2077114, lng: -75.5630352};
            var map = new google.maps.Map(elem, {
                center: self.center,
                zoom: self.zoom,
                zoomControl: self.zoomControl,
                scaleControl: false,
                fullscreenControl: false,
                mapTypeControl: false,
                fitToMarkers: self.fitToMarkers,
                draggable: self.draggable,
                streetViewControl: self.streetViewControl,
                apiKey: self.apiKey,
                mapTypeId: self.mapType
            });

            map.addListener('click', self._onMapClick);
            map.addListener('dragend', self._onMapDragEnd);
            self._map = map;
            self.addMarkers(map, google);
        });

    }

    // Markers
    addMarkers(map, google) {
        this.clearMarkers();
        var self = this;
        this._googleMarkers = this._markers.map(function(m){
            var marker = new google.maps.Marker(m) 
            marker.setMap(map);
            marker.addListener('dragend', self._onMarkerDragEnd);

            var popup = new self.google.maps.InfoWindow(m.infoWindow);

            marker.addListener('click', function(e) {
                self._onMarkerClick(e);
                if (popup.getContent()){
                    popup.open(map, this);
                }
            });

            return marker
        });

        if (this.fitToMarkers) {
            this.fitToMarkerBounds();
        }

        return this._googleMarkers
    }

    clearMarkers() {
        this._googleMarkers.forEach(function(m){
            if (m) {
                m.setMap(null); 
            }
        });
        this._googleMarkers = [];
    }

    fitToMarkerBounds() { // Calculate the bounds to fit all markers
        var latLngBounds = new this.google.maps.LatLngBounds();
        this._markers.forEach(function(m){
            latLngBounds.extend(m.position); 
        });
		
		if (this._markers.length > 1) {
              this._map.fitBounds(latLngBounds);
        }

        if (this._markers.length > 0) {
            this._map.setCenter(latLngBounds.getCenter());
        }
    }



    //Event handlers
    _onMapClick(e) {
        const customEvent = new CustomEvent('googlemap.click', {
            bubbles: true, 
            composed: true,
            detail: { 'latitude': e.latLng.lat(), 'longitude': e.latLng.lng() }
        });
        this.dispatchEvent(customEvent);
    }

    _onMapDragEnd(e) {
        const customEvent = new CustomEvent('googlemap.dragend', {
            bubbles: true, 
            composed: true,
            detail: { 'latitude': this._map.center.lat(), 'longitude': this._map.center.lng() }
        });
        this.dispatchEvent(customEvent);
    }

    _onMarkerClick(e) {
        const clickEvent = new CustomEvent('google-map-marker.click', {
            bubbles: true, 
            composed: true,
            detail: { 'latitude': e.latLng.lat(), 'longitude': e.latLng.lng() }
        });
        this.dispatchEvent(clickEvent);
    }

    _onMarkerDragEnd(e) {
        const dragEvent = new CustomEvent('google-map-marker.dragend', {
            bubbles: true, 
            composed: true,
            detail: { 'latitude': e.latLng.lat(), 'longitude': e.latLng.lng() }
        });
        this.dispatchEvent(dragEvent);
    }

    // Template
    get template() {
        if (this._template) {return this._template;}

        this._template = document.createElement('template');
        let styles = document.createElement('style');
        let content = document.createElement('div');
        let imports = document.createElement('head');

        content.id = 'customMap';

        imports.innerHTML = `
        `;

        styles.innerHTML = `
        div#customMap {
            height: var(--google-map-height, 300px);
        }
        `;

        content.innerHTML = `
        `;


        this._template.content.appendChild(styles);
        this._template.content.appendChild(imports);
        this._template.content.appendChild(content);
        return this._template;
    }
}

customElements.define('google-map', GoogleMap);
