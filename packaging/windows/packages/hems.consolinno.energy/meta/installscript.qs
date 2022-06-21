function Component()
{
    gui.pageWidgetByObjectName("LicenseAgreementPage").entered.connect(changeLicenseLabels);
}

changeLicenseLabels = function()
{
    page = gui.pageWidgetByObjectName("LicenseAgreementPage");
    page.AcceptLicenseLabel.setText("Yes, I agree");
    page.RejectLicenseLabel.setText("No, I disagree");
}

Component.prototype.createOperations = function()
{
    component.createOperations();
    component.addOperation("Execute", "@TargetDir@/vc_redist.x64.exe", "/quiet", "/norestart");
    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut", "@TargetDir@/consolinno-energy.exe", "@StartMenuDir@/Consolinno energy.lnk",
            "workingDirectory=@TargetDir@", "iconPath=@TargetDir@/logo.ico",
            "description=Consolinno energy - The Leaflet frontend");
    }
}
