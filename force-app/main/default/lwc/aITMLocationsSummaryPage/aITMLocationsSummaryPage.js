import { LightningElement, api, track, wire } from "lwc";
import ID_FIELD from "@salesforce/schema/AITM_Tender_Location__c.Id";
import CUSTOMER_DEFAULT from "@salesforce/schema/AITM_Tender_Location__c.AITM_CustomerDefaultValue__c";
import { updateRecord } from "lightning/uiRecordApi";
import getLocationsData from "@salesforce/apex/AITM_CountryByTenderLocationItemCtrl.initializeSummaryCountryDetailResults";
import getLocationData from "@salesforce/apex/AITM_CountryByTenderLocationItemCtrl.initializeCountryDetailResults";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import doUpdateForSelectedLines from "@salesforce/apex/AITM_TenderLocationNewOffer.updateRecord";
import CURRENCYFIELD from "@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Currency__c";
import UOMFIELD from "@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Unit_Of_Measure__c";
import TLLI_OBJECT from "@salesforce/schema/AITM_Tender_Location_Line_Item__c";
import { registerListener, unregisterAllListeners, fireEvent } from "c/pubsub";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { refreshApex } from "@salesforce/apex";
import STATUSFIELD from "@salesforce/schema/AITM_Tender_Location__c.AITM_Status__c";
import TL_OBJECT from "@salesforce/schema/AITM_Tender_Location__c";
import { Toast } from "c/sharedUtils";
import DEBRIEF_STAGE from "@salesforce/label/c.AITM_DebriefStage";

export default class AITMLocationsSummaryPage extends LightningElement {
  @track changedLine = [];

  @track lines = [];

  @track customLines = [];

  @track locationWithLines = [];

  @track filteredLocationWithLines = [];

  priorFilteredLocationWithLines = [];

  statusOptions = [];

  uomOptions = [];

  currencyOptions = [];

  selSearchedLoc;

  slicedRound;

  @api
  markedCheckboxes = [];

  @api
  concatenatedLineTLCountryId = [];

  calledViaPartialRefresh = false;

  @track refreshTable;

  @track loading = true;

  @track locations = [];

  @wire(CurrentPageReference) pageRef;

  @api toggleView;

  @api clickedCountry;

  boolIsError = false;

  openDeliveryModal = false;

  openPricingModal = false;

  selSearchedLineId;

  statusToChange;

  @api
  get lineId() {
    return this.getAttribute("lineId");
  }

  set lineId(value) {
    this.setAttribute("lineId", value);
  }

  @api
  get tenderId() {
    return this.getAttribute("tenderId");
  }

  set tenderId(value) {
    this.setAttribute("tenderId", value);
  }

  @api
  get selectedRound() {
    return this.getAttribute("selectedRound");
  }

  set selectedRound(value) {
    this.setAttribute("selectedRound", value);
  }

  @api
  get selectedCountry() {
    return this.getAttribute("selectedCountry");
  }

  set selectedCountry(value) {
    this.setAttribute("selectedCountry", value);
  }

  @api
  get expandAll() {
    return this.getAttribute("expandAll");
  }

  set expandAll(value) {
    this.setAttribute("expandAll", value);
  }

  @api
  get lastElement() {
    return this.getAttribute("lastElement");
  }

  set lastElement(value) {
    this.setAttribute("lastElement", value);
  }

  @api
  get highlight() {
    return this.getAttribute("highlight");
  }

  set highlight(value) {
    this.setAttribute("highlight", value);
    if (!value) this.resetRowColor();
  }

  get enableDisplay() {
    return true;
  }

  toggleSpinner(isVisible) {
    this.loading = isVisible;
  }

  renderedCallback() {
    Array.from(this.template.querySelectorAll("lightning-input")).forEach(
      (elem) => {
        if (elem) {
          let style = document.createElement("style");
          style.innerHTML = `.paddingRemovalCSS .slds-input{
                    padding: 0px !important;
                }`;
          elem.appendChild(style);
        }
      }
    );

    Array.from(
      this.template.querySelectorAll("lightning-formatted-text")
    ).forEach((elem) => {
      if (elem) {
        let style = document.createElement("style");
        style.innerHTML = `.overflowCSS .slds-input{
                    overflow: hidden !important;
                }`;
        elem.appendChild(style);
      }
    });
  }

  connectedCallback() {
    registerListener("refreshexpand", this.callBackExpandAllMethod, this);
    registerListener(
      "refreshparent",
      this.refreshLeftAfterChangesFromRight,
      this
    );
    registerListener("refreshaftermodal", this.refreshSections, this);
    registerListener(
      "refreshlocations",
      this.callBackRefreshLocationsMethod,
      this
    );
    registerListener("handlerevision", this.callBackhandleRevision, this);
  }

  callBackExpandAllMethod(payload) {
    this.expandAll = payload;
    this.enableDisplay();
  }

  callBackRefreshLocationsMethod(payload) {
    this.handleUncheckingAfterOperation();
    this.markedCheckboxes = [];
    this.calledViaPartialRefresh = true;
    refreshApex(this.refreshTable);
  }

  refreshLeftAfterChangesFromRight() {
    refreshApex(this.refreshTable);
  }

  disconnectedCallback() {
    unregisterAllListeners(this);
  }

  @wire(getObjectInfo, { objectApiName: TL_OBJECT })
  tlConfigObjectInfo;

  @wire(getLocationsData, {
    tenderId: "$tenderId",
    countryName: "$selectedCountry",
    roundNumber: "$selectedRound",
  })
  wiredLocationsData(result) {
    this.refreshTable = result;
    if (result.data) {
      this.locationWithLines = result.data.results;
      this.initializeLocationWithLines();
      if (!this.calledViaPartialRefresh) {
        this.currencyOptions = this.decodeToOptions(
          result.data.optionsCurrency
        );
        this.uomOptions = this.decodeToOptions(result.data.optionsUom);
        this.statusOptions = this.decodeToOptions(result.data.optionsStatus);
      } else this.handleUncheckingAfterOperation();
      this.calledViaPartialRefresh = false;
      this.toggleSpinner(false);
    }
  }

  initializeLocationWithLines() {
    this.filteredLocationWithLines = [];
    this.priorFilteredLocationWithLines = [];
    let location = {};
    let lines = [];
    let priorLocation = {};
    let priorLines = [];
    for (let key in this.locationWithLines) {
      var firstLine = this.locationWithLines[key][0];
      location = {
        AITM_IATA_ICAO__c: key,
        country: this.selectedCountry,
        Key: firstLine.locationId,
        Name: firstLine.locationName,
        Id: firstLine.locationId,
        AITM_Status__c: firstLine.status,
        AITM_Tender_Location__c: firstLine.tenderLocationId,
        lines: [],
      };
      this.locationWithLines[key].forEach((line) => {
        lines.push({
          Key: line.recordId,
          recordId: line.recordId,
          Id: line.recordId,
          colorCode: false,
          style: "",
          AITM_Start_Date__c: line.tlli.AITM_Start_Date__c,
          AITM_End_Date__c: line.tlli.AITM_End_Date__c,
          Customer: line.customer,
          GRN: line.tlli.AITM_Account__r.AITM_GRN__c,
          Debrief: this.calculateDebrief(
            line.tlli.AITM_Tender_Location__r.AITM_Stage__c
          ),
          selectedChecked: false,
          tooTipForCustomer: false,
          tooTipForVolume: false,
          tooTipForPricing: false,
          tooTipForDelivery: false,
          tooTipForPercentage: false,
          AITM_Type: line.tlli.AITM_Pricing_Type__c,
          AITM_Pricing_Basis__c: line.pricingBasisId,
          PricingBasisName: line.pricingBasis,
          OfferedVolume: this.rectifyValue(line.tlli.AITM_Offered_Volume__c, 0),
          AITM_Percentage_Volume_Offered__c:
            line.tlli.AITM_Percentage_Volume_Offered__c,
          AITM_Location_Delivery_Point__c: line.deliveryPointId,
          DeliveryPointName: line.deliveryPointName,
          AITM_Offered_Volume__c: line.tlli.AITM_Offered_Volume__c,
          AITM_Requested_Volume_USG__c: line.tlli.AITM_Requested_Volume_USG__c,
          AITM_Unit_Of_Measure__c: line.tlli.AITM_Unit_Of_Measure__c,
          AITM_Currency__c: line.tlli.AITM_Currency__c,
          AITM_Previous_Round_Differential__c:
            line.tlli.AITM_Previous_Round_Differential__c,
          AITM_Current_Value__c: line.tlli.AITM_Current_Value__c,
          AITM_Offered_Differential__c: line.tlli.AITM_Offered_Differential__c,
          AITM_Tender_Location__c: line.tenderLocationId,
          AITM_Status__c: line.status,
          AITM_Product_Default__c: line.tlli.AITM_Product_Default__c,
          AITM_Delivery_Method__c: line.tlli.AITM_Delivery_Method__c,
          AITM_Delivery_Point_Info__c: line.tlli.AITM_Delivery_Point_Info__c,
          AITM_Classification:
            line.tlli.AITM_Account__r.AITM_Account_Classification__c,
          country: line.country,
          uniqueLocIdentifier: key,
        });
      });
      location.lines = lines;
      lines = [];
      this.filteredLocationWithLines.push(location);
    }
  }

  //changes by shweta
  handleAdsChange(event) {
    alert("alert3");
    let locationId = event.target.dataset.value;
    console.log("location id " + locationId);
    if (event.target.checked) {
      alert("alert1");
      const fields = {};
      fields[ID_FIELD.fieldApiName] = locationId;
      fields[CUSTOMER_DEFAULT.fieldApiName] = 0;
      const recordInput = { fields };
      updateRecord(recordInput)
        .then((result) => {
          console.log("result is " + result);
        })
        .catch((error) => {
          console.log("error is " + error);
        });
    } else {
      alert("alert2");
      const fields = {};
      fields[ID_FIELD.fieldApiName] = locationId;
      fields[CUSTOMER_DEFAULT.fieldApiName] = 4;
      const recordInput = { fields };
      updateRecord(recordInput)
        .then((result) => {
          console.log("result is " + result);
        })
        .catch((error) => {
          console.log("error is " + error);
        });
    }
  }

  resetRowColor() {
    Array.from(this.template.querySelectorAll("tr.rowHighlightedCSS")).forEach(
      (elem) => {
        elem.classList.remove("blueBackgroundCSS");
      }
    );
  }

  handleRowHighlight(event) {
    var isApplyAllDisabled = this.calculateApplyAllDisabled(
      event.currentTarget.dataset.tl
    );
    Array.from(this.template.querySelectorAll("tr.rowHighlightedCSS")).forEach(
      (elem) => {
        const lightningInput = elem;
        if (lightningInput.innerHTML.includes(event.target.value))
          lightningInput.classList.add("blueBackgroundCSS");
        else lightningInput.classList.remove("blueBackgroundCSS");
      }
    );
    const param = [];
    param.push({
      lineId: event.target.value,
      tenderLocId: event.currentTarget.dataset.tl,
      country: event.target.name,
      isApplyAllDisabled: isApplyAllDisabled,
    });
    const refreshsummaryrightpanel = new CustomEvent(
      "refreshsummaryrightpanel",
      {
        detail: {
          lineId: event.target.value,
          tenderLocId: event.currentTarget.dataset.tl,
          country: event.target.name,
          isApplyAllDisabled: isApplyAllDisabled,
        },
      }
    );
    this.dispatchEvent(refreshsummaryrightpanel);
    fireEvent(this.pageRef, "refreshsummaryrightpanel", param);

    const sendrightpanelcountry = new CustomEvent("sendrightpanelcountry", {
      detail: {
        lineId: event.target.value,
        tenderLocId: event.currentTarget.dataset.tl,
        country: event.target.name,
        isApplyAllDisabled: isApplyAllDisabled,
      },
    });
    this.dispatchEvent(sendrightpanelcountry);
    fireEvent(this.pageRef, "sendrightpanelcountry", param);
  }

  toggleToEditStatus(event) {
    this.template
      .querySelector(".toggle-edit-block")
      .classList.remove("hideCSS");
    this.template.querySelector(".toggle-text-block").classList.add("hideCSS");
  }

  hideEditBlock() {
    this.template.querySelector(".toggle-edit-block").classList.add("hideCSS");
    this.template
      .querySelector(".toggle-text-block")
      .classList.remove("hideCSS");
  }

  handleMouseOverToolTip(event) {
    this.filteredLocationWithLines.forEach((ins) => {
      if (ins.AITM_IATA_ICAO__c === event.currentTarget.dataset.unique) {
        ins.lines = ins.lines.map((item) => {
          var temp = Object.assign({}, item);
          if (temp.Id == event.currentTarget.dataset.idx) {
            temp.tooTipForPricing =
              event.target.name == "AITM_Pricing_Basis__c"
                ? true
                : temp.tooTipForPricing;
            temp.tooTipForDelivery =
              event.target.name == "AITM_Location_Delivery_Point__c"
                ? true
                : temp.tooTipForDelivery;
            temp.tooTipForPercentage =
              event.target.name == "AITM_Percentage_Volume_Offered__c"
                ? true
                : temp.tooTipForPercentage;
            temp.tooTipForCustomer =
              event.target.name == "CustomerName"
                ? true
                : temp.tooTipForCustomer;
            temp.tooTipForVolume =
              event.target.name == "AITM_Requested_Volume_USG__c"
                ? true
                : temp.tooTipForVolume;
          }
          return temp;
        });
      }
    });
  }

  handleMouseOutToolTip(event) {
    this.filteredLocationWithLines.forEach((ins) => {
      if (ins.AITM_IATA_ICAO__c === event.currentTarget.dataset.unique) {
        ins.lines = ins.lines.map((item) => {
          var temp = Object.assign({}, item);
          if (temp.Id == event.currentTarget.dataset.idx) {
            temp.tooTipForPricing =
              event.target.name == "AITM_Pricing_Basis__c"
                ? false
                : temp.tooTipForPricing;
            temp.tooTipForDelivery =
              event.target.name == "AITM_Location_Delivery_Point__c"
                ? false
                : temp.tooTipForDelivery;
            temp.tooTipForPercentage =
              event.target.name == "AITM_Percentage_Volume_Offered__c"
                ? false
                : temp.tooTipForPercentage;
            temp.tooTipForCustomer =
              event.target.name == "CustomerName"
                ? false
                : temp.tooTipForCustomer;
            temp.tooTipForVolume =
              event.target.name == "AITM_Requested_Volume_USG__c"
                ? false
                : temp.tooTipForVolume;
          }
          return temp;
        });
      }
    });
  }

  rectifyValue(str, type) {
    if (str) return str;
    return type;
  }

  decodeToOptions(picklistValues) {
    let arr = [];
    const options = [];
    for (let i = 0; i < picklistValues.length; i += 1) {
      options.push({ label: picklistValues[i], value: picklistValues[i] });
    }
    return options;
  }

  convertDateToSpecificFormat1(date_input) {
    if (date_input) {
      const monthNames = [
        "JAN",
        "FEB",
        "MAR",
        "APR",
        "MAY",
        "JUN",
        "JUL",
        "AUG",
        "SEP",
        "OCT",
        "NOV",
        "DEC",
      ];
      var dateToBeFormatted = new Date(date_input);
      let day = String(dateToBeFormatted.getDate()).padStart(2, "0");
      let month = String(monthNames[dateToBeFormatted.getMonth()]);
      let year = dateToBeFormatted.getFullYear();
      let slicedYear = year.toString().substr(-2);
      var decodedDate = day + "-" + month + "-" + slicedYear;
      return decodedDate;
    }
    return "";
  }
  convertDateToSpecificFormat(date_input) {
    if (date_input) {
      let dt = new Date(date_input);
      const dtf = new Intl.DateTimeFormat("en", {
        year: "2-digit",
        month: "2-digit",
        day: "2-digit",
      });
      const [
        { value: mo },
        ,
        { value: da },
        ,
        { value: ye },
      ] = dtf.formatToParts(dt);

      let decodedDate = `${da}-${mo}-${ye}`;
      return decodedDate;
    }
    return "";
  }

  fetchLineItems(tlId) {
    var lines = [];
    this.filteredLocationWithLines.forEach((loc) => {
      if (loc.AITM_Tender_Location__c == tlId) lines = loc.lines;
    });
    return lines;
  }

  handleSaveStatus(event) {
    this.toggleSpinner(true);
    this.boolIsError = false;
    var lines = this.fetchLineItems(event.currentTarget.dataset.location);
    this.validatePricingAll(lines);
    //Added by Prashank
   
    // changes end
    if ((!this.boolIsError) && this.statusToChange)
      this.handleUpdateRecord(
        event.target.name,
        event.target.value,
        lines,
        event.currentTarget.dataset.location
      );
    else this.toggleSpinner(false);
  }

  //added by prashank
  makeStausChange(event){
      this.statusToChange = true;
  }

  callBackhandleRevision(payload) {
    var lines = this.fetchLineItems(payload);
    this.handleUpdateRecord("AITM_No_Revision__c", "true", lines, payload);
  }

  handleLineChange(event) {
    this.changedLine = [];
    this.makeTemporaryLineUpdates(
      event.target.name,
      event.target.value,
      event.currentTarget.dataset.line,
      event.currentTarget.dataset.location
    );
    this.fetchLineItem(
      event.currentTarget.dataset.line,
      event.currentTarget.dataset.location
    );
    const handlelinechange = new CustomEvent("handlelinechange", {
      detail: this.changedLine,
    });
    this.dispatchEvent(handlelinechange);
    fireEvent(this.pageRef, "handlelinechange", this.changedLine);
  }

  makeTemporaryLineUpdates(fieldName, fieldValue, lineId, uniqueIdentifier) {
    this.filteredLocationWithLines.forEach((ins) => {
      if (ins.AITM_Tender_Location__c === uniqueIdentifier) {
        ins.lines = ins.lines.map((item) => {
          var temp = Object.assign({}, item);
          if (temp.Id == lineId) {
            temp.AITM_Start_Date__c =
              fieldName == "AITM_Start_Date__c"
                ? fieldValue
                : temp.AITM_Start_Date__c;
            temp.AITM_End_Date__c =
              fieldName == "AITM_End_Date__c"
                ? fieldValue
                : temp.AITM_End_Date__c;
            temp.AITM_Currency__c =
              fieldName == "AITM_Currency__c"
                ? fieldValue
                : temp.AITM_Currency__c;
            temp.AITM_Unit_Of_Measure__c =
              fieldName == "AITM_Unit_Of_Measure__c"
                ? fieldValue
                : temp.AITM_Unit_Of_Measure__c;
            temp.AITM_Offered_Differential__c =
              fieldName == "AITM_Offered_Differential__c"
                ? fieldValue
                : temp.AITM_Offered_Differential__c;
            temp.AITM_Current_Value__c =
              fieldName == "AITM_Current_Value__c"
                ? fieldValue
                : temp.AITM_Current_Value__c;
            temp.AITM_Percentage_Volume_Offered__c =
              fieldName == "AITM_Percentage_Volume_Offered__c"
                ? fieldValue
                : temp.AITM_Percentage_Volume_Offered__c;
          }
          return temp;
        });
      }
    });
  }

  fetchLineItem(lineId, tlId) {
    this.changedLine = [];
    this.filteredLocationWithLines.forEach((loc) => {
      if (loc.AITM_Tender_Location__c == tlId) {
        loc.lines.forEach((line) => {
          if (line.recordId == lineId) this.changedLine.push(line);
        });
      }
    });
  }

  handleUpdateRecord(fieldApi, updatedVal, lineItemsLst, tlId) {
    doUpdateForSelectedLines({
      objectName: "AITM_Tender_Location__c",
      recordId: tlId,
      fieldName: fieldApi,
      value: updatedVal,
      lineItems: lineItemsLst,
    })
      .then((result) => {})
      .catch((error) => {
        Toast.showError(this, error);
      })
      .finally(() => {
        refreshApex(this.refreshTable);
        this.handleUncheckingAfterOperation();
        this.dummyRefreshRightPanel();
        this.refreshParent();
        this.toggleSpinner(false);
      });
  }

  refreshParent() {
    const refreshleftparent = new CustomEvent("refreshleftparent", {
      detail: "",
    });
    this.dispatchEvent(refreshleftparent);
    fireEvent(this.pageRef, "refreshleftparent", "");
  }

  disableToggleSpinner() {
    const togglespinner = new CustomEvent("togglespinner", {
      detail: "",
    });
    this.dispatchEvent(togglespinner);
    fireEvent(this.pageRef, "togglespinner", "");
  }

  dummyRefreshRightPanel() {
    const dummyrefreshchild = new CustomEvent("dummyrefreshchild", {
      detail: "",
    });
    this.dispatchEvent(dummyrefreshchild);
    fireEvent(this.pageRef, "dummyrefreshchild", "");
  }

  dummyRefreshHighestVolumePage() {
    const refreshparent = new CustomEvent("refreshparent", {
      detail: "",
    });
    this.dispatchEvent(refreshparent);
    fireEvent(this.pageRef, "refreshparent", "");
  }

  handleUncheckingAfterOperation() {
    Array.from(this.template.querySelectorAll('[data-id="checkbox"]')).forEach(
      (elem) => {
        elem.checked = false;
      }
    );
    this.markedCheckboxes = [];
    this.concatenatedLineTLCountryId = [];
  }

  handleDelivery(event) {
    this.selSearchedLineId = event.target.value;
    this.selSearchedLoc = event.currentTarget.dataset.location;
    this.openDeliveryModal = true;
  }

  handlePricing(event) {
    this.selSearchedLineId = event.target.value;
    this.openPricingModal = true;
  }

  handleMarkedCheckboxes(event) {
    const param = [];
    param.push({
      lineId: event.target.dataset.line,
      country: event.currentTarget.dataset.country,
      locationId: event.currentTarget.dataset.location,
      operation: event.target.checked ? "add" : "remove",
    });
    const passtickedones = new CustomEvent("passtickedones", {
      detail: {
        lineId: event.target.dataset.line,
        country: event.currentTarget.dataset.country,
        locationId: event.currentTarget.dataset.location,
        operation: event.target.checked ? "add" : "remove",
      },
    });
    this.dispatchEvent(passtickedones);
    fireEvent(this.pageRef, "passtickedones", param);
  }

  refreshSections(payload) {
    this.openDeliveryModal = false;
    this.openPricingModal = false;
    if (payload == "Cancel") {
      this.selSearchedLoc = [];
      this.selSearchedLineId = "";
    } else {
      this.refreshLeftAfterChangesFromRight();
      this.dummyRefreshRightPanel();
    }
  }

  calculateDebrief(stage) {
    if (stage && stage === DEBRIEF_STAGE) return true;
    return false;
  }

  validatePricingAll(lines) {
    this.boolIsError = false;
    var lineItemsErrors = [];
    var result = true;
    lines.forEach((ins) => {
      if (!ins.AITM_Pricing_Basis__c || ins.AITM_Pricing_Basis__c == null) {
        lineItemsErrors.push("Pricing Basis");
        result = false;
      }
      if (
        ins.AITM_Pricing_Basis__c != null &&
        ins.AITM_Type == "C" &&
        (!ins.AITM_Current_Value__c || ins.AITM_Current_Value__c == null)
      ) {
        lineItemsErrors.push("Current Value");
        result = false;
      }
      if (
        ins.AITM_Pricing_Basis__c != null &&
        ins.AITM_Type == "D" &&
        (!ins.AITM_Offered_Differential__c ||
          ins.AITM_Offered_Differential__c == null)
      ) {
        lineItemsErrors.push("Offered Differential");
        result = false;
      }
      if (
        !ins.AITM_Location_Delivery_Point__c ||
        ins.AITM_Location_Delivery_Point__c == null
      ) {
        lineItemsErrors.push("Delivery Point");
        result = false;
      }
      if (!ins.AITM_Currency__c || ins.AITM_Currency__c == null) {
        lineItemsErrors.push("Currency");
        result = false;
      }
      if (!ins.AITM_Unit_Of_Measure__c || ins.AITM_Unit_Of_Measure__c == null) {
        lineItemsErrors.push("Unit Of Measure");
        result = false;
      }
    });
    if (lineItemsErrors.length > 0) {
      lineItemsErrors = lineItemsErrors.filter(function (item, pos, self) {
        return self.indexOf(item) == pos;
      });
      this.boolIsError = true;
      Toast.showError(
        this,
        "Please fill in field(s): " +
          lineItemsErrors.join(", ") +
          " for all Tender Location Items"
      );
    }
    else{
      this.template.querySelector('c-a-i-t-m-location-status-change-modal').openModal(lines);
    }
  }

  calculateApplyAllDisabled(selTelLocId) {
    var result = false;
    if (selTelLocId) {
      var lines = this.fetchLineItems(selTelLocId);
      if ((lines && lines.length == 1) || !lines) {
        result = true;
        return result;
      }
      var productDefault = lines[0].AITM_Product_Default__c;
      var deliveryType = lines[0].AITM_Delivery_Method__c;
      var deliveryPoint = lines[0].AITM_Delivery_Point_Info__c;
      var accountClassification = lines[0].AITM_Classification;
      lines.forEach((ins) => {
        if (
          productDefault !== ins.AITM_Product_Default__c ||
          deliveryType !== ins.AITM_Delivery_Method__c ||
          deliveryPoint !== ins.AITM_Delivery_Point_Info__c ||
          accountClassification != ins.AITM_Classification
        ) {
          result = true;
          return result;
        }
      });
    }
    return result ? result : false;
  }
}