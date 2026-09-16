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
    // return value 3010 means it need a reboot, but in most cases it is not needed for running Qt application
    // return value 5100 means there's a newer version of the runtime already installed

    component.addOperation("Execute", "{0,3010,1638,5100}", "@TargetDir@/vc_redist.x64.exe", "/quiet", "/norestart");
    if (systemInfo.productType === "windows") {
        // @ProductName@ resolves to <Name> from config.xml, which distribute_assets.sh
        // already patches per whitelabel target. Using it here (instead of a hardcoded
        // "Consolinno energy" string) keeps config.xml the single source of truth for the
        // Start Menu shortcut's display name, so it stays in sync automatically.
        component.addOperation("CreateShortcut", "@TargetDir@/consolinno-energy.exe", "@StartMenuDir@/@ProductName@.lnk",
            "workingDirectory=@TargetDir@", "iconPath=@TargetDir@/logo.ico",
            "description=@ProductName@");

        component.addOperation("Execute", "reg", "add", "HKEY_CLASSES_ROOT\\consolinno-energy", "/ve", "/d", "URL:hems-con-desktop Protocol", "/f");
        component.addOperation("Execute", "reg", "add", "HKEY_CLASSES_ROOT\\consolinno-energy", "/v", "URL Protocol", "/f");
        component.addOperation("Execute", "reg", "add", "HKEY_CLASSES_ROOT\\consolinno-energy\\shell\\open\\command", "/ve", "/d", "\"@TargetDir@\\consolinno-energy.exe\" \"%1\"", "/f");
    }
}
