pragma Singleton
import QtQuick 2.0
import "../../ui/"

StyleBase {
    id: root

    property color consolinnoExtraDark: "#194D25"
    property color consolinnoDark: "#194D25"
    property color consolinnoMedium: Configuration.iconColor
    property color consolinnoLight: "#BDD758"
    property color consolinnoExtraLight: "#BDD758"
    property color consolinnoHighlight: "#189521"
    property color consolinnoHighlightForeground: Configuration.highlightForeground
    property color legendTileIconColor: "#222222"

    // Epex colors
    readonly property color epexColor: "#E056F5"
    readonly property color epexMainLineColor: "#6CCB56"
    readonly property color epexAverageColor: "#C65B5A"
    readonly property color epexCurrentTime: "#2C723C"

    readonly property color epexBarCurrentTime: "#189521"
    readonly property color epexBarPricingPast: "#F4F6F4"
    readonly property color epexBarPricingCurrentTime: "#767676"
    readonly property color epexBarPricingOutOfLimit: "#E0E0E0"
    readonly property color epexBarOutLine: "#FFFFFF"
    readonly property color epexBarMainLineColor: "#BDD786"
    readonly property color barSeriesDisabled: root.epexBarPricingPast

    //Dropdown
    readonly property color boxColor: "#FFFFFF"
    readonly property color borderColor: "transparent"
    readonly property color textColor: root.consolinnoDark
    readonly property color highlightColor: "#20222222"
    readonly property color currentItemColor: root.consolinnoMedium

    // Switch
    readonly property color switchCircleColor: "#F4F6F4"
    readonly property color switchBagroundColor: "#80222222"
    readonly property color switchOnColor: buttonColor

    property real majorFontSize: 16
    property real screenMargins: 16

    property color buttonColor: "#87BD26"
    property real buttonFontSize: 16
    property real buttonTopPading: 16
    property real buttonLeftPadding: 32
    property color textfield: "#767676"

    // Avoid Zero Compensation Info + Dialog
    property color marketPriceColor: "#E056F5"
    property color pvProductionColor: "#FCE487"
    property color socWithoutControllerColor: "#B6B6B6"
    property color socWithControllerColor: "#BDD786"
    property color xAxisColor: "#194D25"
    property color yAxisColor: "#194D25"
    property color arrowColor: "#194D25"

    property color secondaryDark: "#767676"
    backgroundColor: colors.typography_Background_Default
    foregroundColor: consolinnoExtraDark
    subTextColor: "#767676"

    property color legendTileHeaderBgColor: "#3B000000"

    tileOverlayIconColor: consolinnoDark
    property color tabOverlayColor: consolinnoDark
    property color tileOverlayTextColor: "#ffffff"

    accentColor: consolinnoMedium
    iconColor: consolinnoExtraDark

    gray: "#9c9d9d"
    darkGray: "#717171"
    yellow: "#eec00a"
    blue: "#329eba"

    fontFamily: fontsInternal.fonts_Paragraph

    // Button
    readonly property color secondButtonColor: "#189521"
    readonly property color buttonTextColor: "#000000"
    readonly property color buttonTextColorNoBg: buttonTextColor

    // Info colors
    readonly property color dangerBackground: "#FFC3CD"
    readonly property color dangerAccent: "#AA0A24"

    readonly property color warningBackground: "#FFEE89"
    readonly property color warningAccent: "#864A0D"

    readonly property color successBackground: "#BDF5BF"
    readonly property color successAccent: "#18631E"

    //font size and font family
    readonly property font extraSmallFont: newExtraSmallFont
    readonly property font smallFont: newSmallFont
    readonly property font font: newParagraphFont
    readonly property font bigFont: newH1Font
    readonly property font largeFont: newLargeFont
    readonly property font hugeFont: newHugeFont

    //MainMenuCirlce
    readonly property color mainTimeCircle: "#D3D3D3"
    readonly property color mainTimeCircleDivider: "#ffffff"
    readonly property color mainCircleTimeColor: "#5A5A5A"

    readonly property color mainTimeNow: "#808080"

    readonly property color mainInnerCicleFirst: "#b6b6b6"
    readonly property color mainInnerCicleSecond: "#b6b6b6"
    readonly property color mainInnerCicleText: "#303030"



    // New style from here =================================================

    // Fonts for new style.
    readonly property font newExtraSmallFont: Qt.font({
        family: fontsInternal.fonts_Paragraph,
        pixelSize: fontsInternal.typography_Copy_Extra_small_font,
        letterSpacing: fontsInternal.typography_Copy_Extra_small_font_letter_spacing,
        weight: Font.Normal
    })
    readonly property font newExtraSmallFontBold: Qt.font({
        family: fontsInternal.fonts_Paragraph,
        pixelSize: fontsInternal.typography_Copy_Extra_small_font,
        letterSpacing: fontsInternal.typography_Copy_Extra_small_font_letter_spacing,
        weight: Font.DemiBold
    })
    readonly property font newSmallFont: Qt.font({
        family: fontsInternal.fonts_Paragraph,
        pixelSize: fontsInternal.typography_Copy_Small_font,
        letterSpacing: fontsInternal.typography_Copy_Small_font_letter_spacing,
        weight: Font.Normal
    })
    readonly property font newSmallFontBold: Qt.font({
        family: fontsInternal.fonts_Paragraph,
        pixelSize: fontsInternal.typography_Copy_Small_font,
        letterSpacing: fontsInternal.typography_Copy_Small_font_letter_spacing,
        weight: Font.Bold
    })
    readonly property font newParagraphFont: Qt.font({
        family: fontsInternal.fonts_Paragraph,
        pixelSize: fontsInternal.typography_Copy_Font,
        letterSpacing: fontsInternal.typography_Copy_Font_letter_spacing,
        weight: Font.Normal
    })
    readonly property font newParagraphFontBold: Qt.font({
        family: fontsInternal.fonts_Paragraph,
        pixelSize: fontsInternal.typography_Copy_Font,
        letterSpacing: fontsInternal.typography_Copy_Font_letter_spacing,
        weight: Font.DemiBold
    })
    readonly property font newH1Font: Qt.font({
        family: fontsInternal.fonts_Headline,
        pixelSize: fontsInternal.typography_Headings_H1,
        letterSpacing: fontsInternal.typography_Headings_H1_letter_spacing,
        weight: Font.Bold
    })
    readonly property font newH2Font: Qt.font({
        family: fontsInternal.fonts_Headline,
        pixelSize: fontsInternal.typography_Headings_H2,
        letterSpacing: fontsInternal.typography_Headings_H2_letter_spacing,
        weight: Font.Bold
    })
    readonly property font newH3Font: Qt.font({
        family: fontsInternal.fonts_Headline,
        pixelSize: fontsInternal.typography_Headings_H3,
        letterSpacing: fontsInternal.typography_Headings_H3_letter_spacing,
        weight: Font.Bold
    })
    readonly property font newLargeFont: Qt.font({
        family: fontsInternal.fonts_Headline,
        pixelSize: fontsInternal.typography_Display_Large_font,
        letterSpacing: fontsInternal.typography_Display_Large_font_letter_spacing,
        weight: Font.Bold
    })
    readonly property font newHugeFont: Qt.font({
        family: fontsInternal.fonts_Headline,
        pixelSize: fontsInternal.typography_Display_Huge_font,
        letterSpacing: fontsInternal.typography_Display_Huge_font_letter_spacing,
        weight: Font.Bold
    })

    // Figma Export from Joseph: AppNumbers and AppStrings instances in App.qml
    QtObject {
        id: fontsInternal
        readonly property string fonts_Headline: "Poppins"
        readonly property string fonts_Paragraph: "DM Sans"

        readonly property double typography_Copy_Extra_small_font: 10
        readonly property double typography_Copy_Extra_small_font_letter_spacing: 0.264
        readonly property double typography_Copy_Font: 16
        readonly property double typography_Copy_Font_letter_spacing: 0.139
        readonly property double typography_Copy_Large_font: 32
        readonly property double typography_Copy_Large_font_letter_spacing: -0.195
        readonly property double typography_Copy_Small_font: 13
        readonly property double typography_Copy_Small_font_letter_spacing: 0.151
        readonly property double typography_Headings_H1: 21.6
        readonly property double typography_Headings_H1_letter_spacing: 0.216
        readonly property double typography_Headings_H2: 18
        readonly property double typography_Headings_H2_letter_spacing: 0.36
        readonly property double typography_Headings_H3: 16
        readonly property double typography_Headings_H3_letter_spacing: 0.6
        readonly property double typography_Display_Huge_font: 46
        readonly property double typography_Display_Huge_font_letter_spacing: -0.2
        readonly property double typography_Display_Large_font: 32
        readonly property double typography_Display_Large_font_letter_spacing: 0
    }

    // Colors for new style.
    // Figma Export from Joseph: AppColors instances in App.qml
    readonly property QtObject colors: QtObject {
        readonly property color brand_Basic_Accent: brand_Primary_Medium_darker
        readonly property color brand_Basic_Accent_high_contrast: brand_Primary_Dark
        readonly property color brand_Basic_Icon: typography_Basic_Default
        readonly property color brand_Basic_Icon_accent: brand_Basic_Accent
        readonly property color brand_Primary_Dark: baseColors.consolinno_Green_900
        readonly property color brand_Primary_Dark_12: baseColors.consolinno_Green_900_12
        readonly property color brand_Primary_Dark_24: baseColors.consolinno_Green_900_24
        readonly property color brand_Primary_Light: baseColors.consolinno_Green_200
        readonly property color brand_Primary_Light_12: baseColors.consolinno_Green_200_12
        readonly property color brand_Primary_Light_24: baseColors.consolinno_Green_200_24
        readonly property color brand_Primary_Medium: baseColors.consolinno_Green_300
        readonly property color brand_Primary_Medium_darker: baseColors.consolinno_Green_600
        readonly property color brand_Secondary_Accent: baseColors.consolinno_Secondary_Mint
        readonly property color brand_Secondary_Dark: baseColors.consolinno_Gray_900
        readonly property color brand_Secondary_Darker: baseColors.consolinno_Gray_950
        readonly property color brand_Secondary_Light: baseColors.consolinno_Gray_50
        readonly property color brand_Secondary_Medium: baseColors.consolinno_Gray_500
        readonly property color components_Dashboard_Background_accent_dashboard: menu_Header_Footer_Background
        readonly property color components_Dashboard_Background_gradient_bottom: brand_Primary_Medium
        readonly property color components_Dashboard_Background_gradient_top: brand_Primary_Light
        readonly property color components_Dashboard_Detail_Energy_circle: typography_Background_Default
        readonly property color components_Dashboard_Detail_Energy_circle_border: brand_Secondary_Accent
        readonly property color components_Dashboard_Detail_Energy_circle_empty: typography_Background_Accent
        readonly property color components_Dashboard_Detail_Energy_circle_glow: brand_Secondary_Accent
        readonly property color components_Dashboard_Flow: typography_Basic_Default_high_contrast
        readonly property color components_Dashboard_Info_card_title: typography_Headlines_H2
        readonly property color components_Dashboard_Info_card_value: typography_Basic_Default
        readonly property color components_Datepicker_Selection_background: typography_Basic_Color_Emphasize
        readonly property color components_Datepicker_Selection_text: typography_Background_Default
        readonly property color components_Datepicker_Today: typography_Basic_Color_Emphasize
        readonly property color components_EPEX_Charging: brand_Primary_Dark_24
        readonly property color components_EPEX_EPEX: typography_Basic_Color_Emphasize
        readonly property color components_EPEX_Limit: system_Danger_Background
        readonly property color components_EPEX_Limit_border: system_Danger_Accent
        readonly property color components_Forms_Buttons_Button_border_focus: typography_Background_Default
        readonly property color components_Forms_Buttons_Button_primary: brand_Primary_Medium
        readonly property color components_Forms_Buttons_Button_primary_border: brand_Basic_Accent_high_contrast
        readonly property color components_Forms_Buttons_Button_primary_text: brand_Secondary_Dark
        readonly property color components_Forms_Buttons_Button_secondary_is_current: typography_Basic_Default
        readonly property color components_Forms_Buttons_Button_secondary_is_current_1: typography_Background_Default
        readonly property color components_Forms_Buttons_Button_secondary_text: typography_Basic_Default
        readonly property color components_Forms_Fields_Field_border: typography_Basic_Secondary
        readonly property color components_Forms_Fields_Field_border_active: brand_Basic_Accent
        readonly property color components_Forms_Fields_Field_border_hover: typography_States_Hover_pressed_outline
        readonly property color components_Forms_Fields_Field_label: typography_Basic_Default
        readonly property color components_Forms_Fields_Field_user_input: typography_Basic_Default
        readonly property color components_Forms_Selection_controls_Selected: brand_Basic_Accent_high_contrast
        readonly property color components_Forms_Selection_controls_Unselected: brand_Secondary_Medium
        readonly property color components_Forms_Slider_Handle: brand_Basic_Accent_high_contrast
        readonly property color components_Forms_Slider_Handle_hover_accent: brand_Primary_Dark_12
        readonly property color components_Forms_Slider_Handle_pressed_accent: brand_Primary_Dark_24
        readonly property color components_Forms_Slider_Track: brand_Basic_Accent_high_contrast
        readonly property color components_Forms_Toggle_Handle_active: brand_Basic_Accent_high_contrast
        readonly property color components_Forms_Toggle_Handle_inactive: brand_Secondary_Light
        readonly property color components_Forms_Toggle_Track_active: brand_Basic_Accent_high_contrast
        readonly property color components_Forms_Toggle_Track_inactive: brand_Secondary_Medium
        readonly property color components_Navigation_Nav_entry: typography_Basic_Default
        readonly property color components_Navigation_Tabs_Background: typography_Background_Accent
        readonly property color components_Navigation_Tabs_Selected: typography_Background_Selection
        readonly property color components_Navigation_Tabs_Selected_Border: baseColors.consolinno_Gray_500
        readonly property color components_Navigation_Tabs_Text: brand_Secondary_Dark
        readonly property color components_Navigation_Tabs_Text_selected: typography_Basic_Default
        readonly property color components_Statistics_Grid: typography_Background_Accent
        readonly property color components_Statistics_Legend_pill_text: brand_Secondary_Darker
        readonly property color components_Statistics_Legend_pill_text_unselecte: typography_Basic_Default_high_contrast
        readonly property color components_Statistics_Tariff_controlled_charging: baseColors.consolinno_Gray_100
        readonly property color components_Statistics_Tariff_controlled_charging_1: brand_Basic_Accent
        readonly property color components_Statistics_Tariff_controlled_charging_2: typography_Basic_Secondary
        readonly property color components_Statistics_Tariff_controlled_charging_3: components_Statistics_Things_and_states_Battery
        readonly property color components_Statistics_Tariff_controlled_charging_4: typography_Background_Accent
        readonly property color components_Statistics_Tariff_controlled_charging_5: brand_Basic_Accent
        readonly property color components_Statistics_Tariff_controlled_charging_6: typography_Basic_Secondary
        readonly property color components_Statistics_Things_and_states_Addition: baseColors.defaults_Diagram_Fill_19
        readonly property color components_Statistics_Things_and_states_Addition_1: baseColors.defaults_Diagram_Border_19
        readonly property color components_Statistics_Things_and_states_Addition_10: baseColors.defaults_Diagram_Border_11
        readonly property color components_Statistics_Things_and_states_Addition_11: baseColors.defaults_Diagram_Border_12
        readonly property color components_Statistics_Things_and_states_Addition_12: baseColors.defaults_Diagram_Border_13
        readonly property color components_Statistics_Things_and_states_Addition_13: baseColors.defaults_Diagram_Border_14
        readonly property color components_Statistics_Things_and_states_Addition_14: baseColors.defaults_Diagram_Border_15
        readonly property color components_Statistics_Things_and_states_Addition_15: baseColors.defaults_Diagram_Border_16
        readonly property color components_Statistics_Things_and_states_Addition_16: baseColors.defaults_Diagram_Border_17
        readonly property color components_Statistics_Things_and_states_Addition_17: baseColors.defaults_Diagram_Border_18
        readonly property color components_Statistics_Things_and_states_Addition_2: baseColors.defaults_Diagram_Fill_11
        readonly property color components_Statistics_Things_and_states_Addition_3: baseColors.defaults_Diagram_Fill_12
        readonly property color components_Statistics_Things_and_states_Addition_4: baseColors.defaults_Diagram_Fill_13
        readonly property color components_Statistics_Things_and_states_Addition_5: baseColors.defaults_Diagram_Fill_14
        readonly property color components_Statistics_Things_and_states_Addition_6: baseColors.defaults_Diagram_Fill_15
        readonly property color components_Statistics_Things_and_states_Addition_7: baseColors.defaults_Diagram_Fill_16
        readonly property color components_Statistics_Things_and_states_Addition_8: baseColors.defaults_Diagram_Fill_17
        readonly property color components_Statistics_Things_and_states_Addition_9: baseColors.defaults_Diagram_Fill_18
        readonly property color components_Statistics_Things_and_states_Battery: baseColors.defaults_Diagram_Fill_7
        readonly property color components_Statistics_Things_and_states_Battery_: baseColors.defaults_Diagram_Fill_10
        readonly property color components_Statistics_Things_and_states_Battery_1: baseColors.defaults_Diagram_Fill_9
        readonly property color components_Statistics_Things_and_states_Battery__2: baseColors.defaults_Diagram_Border_7
        readonly property color components_Statistics_Things_and_states_Battery__3: baseColors.defaults_Diagram_Border_9
        readonly property color components_Statistics_Things_and_states_Battery__4: baseColors.defaults_Diagram_Border_10
        readonly property color components_Statistics_Things_and_states_Consumpt: baseColors.defaults_Diagram_Fill_8
        readonly property color components_Statistics_Things_and_states_Consumpt_1: baseColors.defaults_Diagram_Border_8
        readonly property color components_Statistics_Things_and_states_Heat_pum: baseColors.defaults_Diagram_Fill_4
        readonly property color components_Statistics_Things_and_states_Heat_pum_1: baseColors.defaults_Diagram_Border_4
        readonly property color components_Statistics_Things_and_states_Heating_: baseColors.defaults_Diagram_Fill_6
        readonly property color components_Statistics_Things_and_states_Heating_1: baseColors.defaults_Diagram_Border_6
        readonly property color components_Statistics_Things_and_states_Inverter: baseColors.defaults_Diagram_Fill_3
        readonly property color components_Statistics_Things_and_states_Inverter_1: baseColors.defaults_Diagram_Border_3
        readonly property color components_Statistics_Things_and_states_Root_met: baseColors.defaults_Diagram_Fill_1
        readonly property color components_Statistics_Things_and_states_Root_met_1: baseColors.defaults_Diagram_Fill_2
        readonly property color components_Statistics_Things_and_states_Root_met_2: baseColors.defaults_Diagram_Border_1
        readonly property color components_Statistics_Things_and_states_Root_met_3: baseColors.defaults_Diagram_Border_2
        readonly property color components_Statistics_Things_and_states_Wallbox: baseColors.defaults_Diagram_Fill_5
        readonly property color components_Statistics_Things_and_states_Wallbox_: baseColors.defaults_Diagram_Border_5
        readonly property color components_Statistics_Tooltip_background: baseColors.consolinno_Gray_50_67
        readonly property color components_Statistics_Tooltip_border: typography_Basic_Default
        readonly property color components_Statistics_Tooltip_line: typography_Basic_Default
        readonly property color menu_Header_Footer_Background: baseColors.consolinno_Gray_50_67
        readonly property color menu_Header_Footer_Border: typography_Background_Default
        readonly property color system_Danger_Accent: system_Danger_Dark
        readonly property color system_Danger_Background: system_Danger_Light
        readonly property color system_Danger_Dark: baseColors.defaults_Red_Ribbon_800
        readonly property color system_Danger_Darker: baseColors.defaults_Red_Ribbon_950
        readonly property color system_Danger_Light: baseColors.defaults_Red_Ribbon_200
        readonly property color system_Danger_Medium: baseColors.defaults_Red_Ribbon_400
        readonly property color system_Danger_Status_light: system_Danger_Light
        readonly property color system_Danger_Status_light_border: system_Danger_Dark
        readonly property color system_Neutral_Accent: system_Neutral_Dark
        readonly property color system_Neutral_Background: system_Neutral_Light
        readonly property color system_Neutral_Dark: baseColors.consolinno_Gray_800
        readonly property color system_Neutral_Darker: baseColors.consolinno_Gray_900
        readonly property color system_Neutral_Light: baseColors.consolinno_Gray_200
        readonly property color system_Neutral_Medium: baseColors.consolinno_Gray_500
        readonly property color system_Neutral_Status_light: system_Neutral_Light
        readonly property color system_Neutral_Status_light_border: system_Neutral_Dark
        readonly property color system_Success_Accent: system_Success_Dark
        readonly property color system_Success_Background: system_Success_Light
        readonly property color system_Success_Dark: baseColors.defaults_Forest_Green_800
        readonly property color system_Success_Darker: baseColors.defaults_Forest_Green_950
        readonly property color system_Success_Light: baseColors.defaults_Forest_Green_200
        readonly property color system_Success_Medium: baseColors.defaults_Forest_Green_500
        readonly property color system_Success_Status_light: system_Success_Light
        readonly property color system_Success_Status_light_border: system_Success_Dark
        readonly property color system_Warning_Accent: system_Warning_Dark
        readonly property color system_Warning_Background: system_Warning_Light
        readonly property color system_Warning_Dark: baseColors.defaults_Mustard_800
        readonly property color system_Warning_Darker: baseColors.defaults_Mustard_950
        readonly property color system_Warning_Light: baseColors.defaults_Mustard_200
        readonly property color system_Warning_Medium: baseColors.defaults_Mustard_400
        readonly property color system_Warning_Status_border: system_Warning_Dark
        readonly property color system_Warning_Status_light: system_Warning_Light
        readonly property color typography_Background_Accent: baseColors.consolinno_Gray_50
        readonly property color typography_Background_Accent_secondary: baseColors.consolinno_Gray_300
        readonly property color typography_Background_Accent_transparent: baseColors.consolinno_Gray_50_0
        readonly property color typography_Background_Default: baseColors.defaults_Black_and_white_White
        readonly property color typography_Background_Default_transparent: baseColors.defaults_Black_and_white_White_0
        readonly property color typography_Background_Overlay: baseColors.consolinno_Gray_950_60
        readonly property color typography_Background_Selection: baseColors.consolinno_Gray_300
        readonly property color typography_Basic_Color_Emphasize: brand_Primary_Dark
        readonly property color typography_Basic_Default: brand_Secondary_Dark
        readonly property color typography_Basic_Default_high_contrast: brand_Secondary_Darker
        readonly property color typography_Basic_Default_inverted: typography_Background_Default
        readonly property color typography_Basic_Divider: typography_Background_Accent_secondary
        readonly property color typography_Basic_Secondary: baseColors.consolinno_Gray_600
        readonly property color typography_Headlines_H1: typography_Basic_Default
        readonly property color typography_Headlines_H2: typography_Basic_Color_Emphasize
        readonly property color typography_Headlines_H3: typography_Basic_Color_Emphasize
        readonly property color typography_Headlines_Screen_Headline: typography_Basic_Color_Emphasize
        readonly property color typography_States_Focus: typography_Basic_Default
        readonly property color typography_States_Hover: baseColors.consolinno_Gray_950_6
        readonly property color typography_States_Hover_pressed_outline: typography_States_Pressed
        readonly property color typography_States_Pressed: baseColors.consolinno_Gray_950_12
    }

    // Base colors. These are the same for every style and whitelabel variant.
    // Figma Export from Joseph: ColorsColors instance in Colors.qml
    QtObject {
        id: baseColors
        readonly property color consolinno_Gray_100: "#ffe0e6e0"
        readonly property color consolinno_Gray_200: "#ffccd7cd"
        readonly property color consolinno_Gray_300: consolinno_Secondary_Gruengrau
        readonly property color consolinno_Gray_400: "#ff98aba3"
        readonly property color consolinno_Gray_50: consolinno_Green_50
        readonly property color consolinno_Gray_500: "#ff7c8f8b"
        readonly property color consolinno_Gray_50_0: "#00f4f6f4"
        readonly property color consolinno_Gray_50_12_5: "#20f4f6f4"
        readonly property color consolinno_Gray_50_25: "#40f4f6f4"
        readonly property color consolinno_Gray_50_60: "#99f4f6f4"
        readonly property color consolinno_Gray_50_67: "#abf4f6f4"
        readonly property color consolinno_Gray_600: "#ff627373"
        readonly property color consolinno_Gray_700: consolinno_Secondary_Anthrazit
        readonly property color consolinno_Gray_800: "#ff3f4b4d"
        readonly property color consolinno_Gray_900: consolinno_Secondary_Powerpoint_Text_Aschgrau
        readonly property color consolinno_Gray_900_0: "#00343e40"
        readonly property color consolinno_Gray_900_67: "#ab343e40"
        readonly property color consolinno_Gray_950: "#ff242b2d"
        readonly property color consolinno_Gray_950_0: "#00242b2d"
        readonly property color consolinno_Gray_950_12: "#1f242b2d"
        readonly property color consolinno_Gray_950_6: "#0f242b2d"
        readonly property color consolinno_Gray_950_60: "#99242b2d"
        readonly property color consolinno_Green_200: "#ffbdd786"
        readonly property color consolinno_Green_200_12: "#1fbdd786"
        readonly property color consolinno_Green_200_24: "#3dbdd786"
        readonly property color consolinno_Green_300: "#ff83bc32"
        readonly property color consolinno_Green_50: "#fff4f6f4"
        readonly property color consolinno_Green_600: "#ff5e9f00"
        readonly property color consolinno_Green_70: "#ffe8ede9"
        readonly property color consolinno_Green_900: "#ff03693a"
        readonly property color consolinno_Green_900_12: "#1f03693a"
        readonly property color consolinno_Green_900_24: "#3d03693a"
        readonly property color consolinno_Secondary_Anthrazit: "#ff4b585b"
        readonly property color consolinno_Secondary_Gruengrau: "#ffb8c8ba"
        readonly property color consolinno_Secondary_Mint: "#ff009878"
        readonly property color consolinno_Secondary_Powerpoint_Text_Aschgrau: "#ff343e40"
        readonly property color consolinno_Secondary_Text_Schwarz: defaults_Black_and_white_Black
        readonly property color defaults_Black_and_white_Black: "#ff000000"
        readonly property color defaults_Black_and_white_White: "#ffffffff"
        readonly property color defaults_Black_and_white_White_0: "#00ffffff"
        readonly property color defaults_Diagram_Border_1: "#ffd8344e"
        readonly property color defaults_Diagram_Border_10: "#ffcc51a6"
        readonly property color defaults_Diagram_Border_11: "#fff55209"
        readonly property color defaults_Diagram_Border_12: "#ff809c6d"
        readonly property color defaults_Diagram_Border_13: "#ff437bc4"
        readonly property color defaults_Diagram_Border_14: "#ffaa5dc2"
        readonly property color defaults_Diagram_Border_15: "#ff989912"
        readonly property color defaults_Diagram_Border_16: "#ff2da900"
        readonly property color defaults_Diagram_Border_17: "#ff0094b6"
        readonly property color defaults_Diagram_Border_18: "#fff26668"
        readonly property color defaults_Diagram_Border_19: "#ff54a800"
        readonly property color defaults_Diagram_Border_2: "#ff0b7aaa"
        readonly property color defaults_Diagram_Border_3: "#ffb59000"
        readonly property color defaults_Diagram_Border_4: "#ffc58643"
        readonly property color defaults_Diagram_Border_5: "#ff00a3a0"
        readonly property color defaults_Diagram_Border_6: "#ff388062"
        readonly property color defaults_Diagram_Border_7: "#ff789931"
        readonly property color defaults_Diagram_Border_8: "#ff536fce"
        readonly property color defaults_Diagram_Border_9: "#ff239981"
        readonly property color defaults_Diagram_Fill_1: "#fff37b8e"
        readonly property color defaults_Diagram_Fill_10: "#ffff84da"
        readonly property color defaults_Diagram_Fill_11: "#ffff8954"
        readonly property color defaults_Diagram_Fill_12: "#ffd9f6c5"
        readonly property color defaults_Diagram_Fill_13: "#ff5fa1f9"
        readonly property color defaults_Diagram_Fill_14: "#ffd6a1e6"
        readonly property color defaults_Diagram_Fill_15: "#ffc6c73f"
        readonly property color defaults_Diagram_Fill_16: "#ff74ed49"
        readonly property color defaults_Diagram_Fill_17: "#ff83e8ff"
        readonly property color defaults_Diagram_Fill_18: "#ffffafb1"
        readonly property color defaults_Diagram_Fill_19: "#ffe1ff37"
        readonly property color defaults_Diagram_Fill_2: "#ff45b4e4"
        readonly property color defaults_Diagram_Fill_3: "#fffce487"
        readonly property color defaults_Diagram_Fill_4: "#fff7b772"
        readonly property color defaults_Diagram_Fill_5: "#fface3e2"
        readonly property color defaults_Diagram_Fill_6: "#ff639f86"
        readonly property color defaults_Diagram_Fill_7: "#ffbdd786"
        readonly property color defaults_Diagram_Fill_8: "#ffadb9e3"
        readonly property color defaults_Diagram_Fill_9: "#ff53d0b7"
        readonly property color defaults_Forest_Green_100: "#ffddfbde"
        readonly property color defaults_Forest_Green_200: "#ffbdf5bf"
        readonly property color defaults_Forest_Green_300: "#ff89ec90"
        readonly property color defaults_Forest_Green_400: "#ff4eda57"
        readonly property color defaults_Forest_Green_50: "#fff0fdf0"
        readonly property color defaults_Forest_Green_500: "#ff26c131"
        readonly property color defaults_Forest_Green_600: "#ff189521"
        readonly property color defaults_Forest_Green_700: "#ff187d20"
        readonly property color defaults_Forest_Green_800: "#ff18631e"
        readonly property color defaults_Forest_Green_900: "#ff16511b"
        readonly property color defaults_Forest_Green_950: "#ff062d0a"
        readonly property color defaults_Mustard_100: "#fffff8c2"
        readonly property color defaults_Mustard_200: "#ffffee89"
        readonly property color defaults_Mustard_300: "#ffffdc42"
        readonly property color defaults_Mustard_400: "#fffdc812"
        readonly property color defaults_Mustard_50: "#fffefbe8"
        readonly property color defaults_Mustard_500: "#ffecae06"
        readonly property color defaults_Mustard_600: "#ffcc8602"
        readonly property color defaults_Mustard_700: "#ffa35e05"
        readonly property color defaults_Mustard_800: "#ff864a0d"
        readonly property color defaults_Mustard_900: "#ff723c11"
        readonly property color defaults_Mustard_950: "#ff431e05"
        readonly property color defaults_Red_Ribbon_100: "#ffffdee3"
        readonly property color defaults_Red_Ribbon_200: "#ffffc3cd"
        readonly property color defaults_Red_Ribbon_300: "#ffff99a9"
        readonly property color defaults_Red_Ribbon_400: "#ffff5f79"
        readonly property color defaults_Red_Ribbon_50: "#fffff0f2"
        readonly property color defaults_Red_Ribbon_500: "#ffff2d4f"
        readonly property color defaults_Red_Ribbon_600: "#fff52244"
        readonly property color defaults_Red_Ribbon_700: "#ffce0727"
        readonly property color defaults_Red_Ribbon_800: "#ffaa0a24"
        readonly property color defaults_Red_Ribbon_900: "#ff8c1024"
        readonly property color defaults_Red_Ribbon_950: "#ff4d020e"
        readonly property color wL_Default_Neutral_Gray_100: "#ffe3e3e3"
        readonly property color wL_Default_Neutral_Gray_200: "#ffd4d4d4"
        readonly property color wL_Default_Neutral_Gray_300: "#ffc4c4c4"
        readonly property color wL_Default_Neutral_Gray_400: "#ffa7a7a7"
        readonly property color wL_Default_Neutral_Gray_50: "#fff5f5f5"
        readonly property color wL_Default_Neutral_Gray_500: "#ff8b8b8b"
        readonly property color wL_Default_Neutral_Gray_50_0: "#00f5f5f5"
        readonly property color wL_Default_Neutral_Gray_50_12_5: "#20f5f5f5"
        readonly property color wL_Default_Neutral_Gray_50_25: "#40f5f5f5"
        readonly property color wL_Default_Neutral_Gray_50_60: "#99f5f5f5"
        readonly property color wL_Default_Neutral_Gray_50_67: "#abf5f5f5"
        readonly property color wL_Default_Neutral_Gray_600: "#ff6f7070"
        readonly property color wL_Default_Neutral_Gray_700: "#ff555656"
        readonly property color wL_Default_Neutral_Gray_800: "#ff484949"
        readonly property color wL_Default_Neutral_Gray_900: "#ff3c3c3c"
        readonly property color wL_Default_Neutral_Gray_900_0: "#003c3c3c"
        readonly property color wL_Default_Neutral_Gray_900_67: "#ab3c3c3c"
        readonly property color wL_Default_Neutral_Gray_950: "#ff2a2a2a"
        readonly property color wL_Default_Neutral_Gray_950_0: "#002a2a2a"
        readonly property color wL_Default_Neutral_Gray_950_12: "#1f2a2a2a"
        readonly property color wL_Default_Neutral_Gray_950_6: "#0f2a2a2a"
        readonly property color wL_Default_Neutral_Gray_950_60: "#992a2a2a"
        readonly property color wL_Default_Primary_200: "#ffffbdf3"
        readonly property color wL_Default_Primary_200_12: "#1fffbdf3"
        readonly property color wL_Default_Primary_200_24: "#3dffbdf3"
        readonly property color wL_Default_Primary_300: "#ffff00d0"
        readonly property color wL_Default_Primary_600: "#ffd500ae"
        readonly property color wL_Default_Primary_900: "#ff98007c"
        readonly property color wL_Default_Primary_900_12: "#1f98007c"
        readonly property color wL_Default_Primary_900_24: "#3d98007c"
        readonly property color wL_Default_Secondary_300: "#ff00aeba"
        readonly property color wL_Zewotherm_Primary_200: "#ffc9e0ee"
        readonly property color wL_Zewotherm_Primary_200_12: "#1fc9e0ee"
        readonly property color wL_Zewotherm_Primary_200_24: "#3dc9e0ee"
        readonly property color wL_Zewotherm_Primary_300: "#ff5e9bff"
        readonly property color wL_Zewotherm_Primary_600: "#ff1456c0"
        readonly property color wL_Zewotherm_Primary_900: "#ff04264b"
        readonly property color wL_Zewotherm_Primary_900_12: "#1f04264b"
        readonly property color wL_Zewotherm_Primary_900_24: "#3d04264b"
        readonly property color wL_Zewotherm_Secondary_300: "#ff3b82f6"
        readonly property color wL_qcells_Diagram_Border_1: "#ffce092f"
        readonly property color wL_qcells_Diagram_Border_10: "#ff0228a0"
        readonly property color wL_qcells_Diagram_Border_2: "#ff07648f"
        readonly property color wL_qcells_Diagram_Border_3: "#ffc19100"
        readonly property color wL_qcells_Diagram_Border_4: "#fff75c03"
        readonly property color wL_qcells_Diagram_Border_5: "#ff364152"
        readonly property color wL_qcells_Diagram_Border_6: "#ff46735f"
        readonly property color wL_qcells_Diagram_Border_7: "#ff636f19"
        readonly property color wL_qcells_Diagram_Border_8: "#ff7f27a4"
        readonly property color wL_qcells_Diagram_Border_9: "#ff018582"
        readonly property color wL_qcells_Diagram_Fill_1: "#fffbc4bb"
        readonly property color wL_qcells_Diagram_Fill_10: "#ffd2dcf1"
        readonly property color wL_qcells_Diagram_Fill_2: "#ffc2e0ef"
        readonly property color wL_qcells_Diagram_Fill_3: "#fffff4b2"
        readonly property color wL_qcells_Diagram_Fill_4: "#fffdceb3"
        readonly property color wL_qcells_Diagram_Fill_5: "#ffeef2f6"
        readonly property color wL_qcells_Diagram_Fill_6: "#ffc7eed4"
        readonly property color wL_qcells_Diagram_Fill_7: "#ffd8eb66"
        readonly property color wL_qcells_Diagram_Fill_8: "#ffe5d4ed"
        readonly property color wL_qcells_Diagram_Fill_9: "#ffa0e3e0"
        readonly property color wL_qcells_Primary_200: "#ffa1e2b7"
        readonly property color wL_qcells_Primary_200_12: "#1fa1e2b7"
        readonly property color wL_qcells_Primary_200_24: "#3da1e2b7"
        readonly property color wL_qcells_Primary_300: "#ff00c6c1"
        readonly property color wL_qcells_Primary_600: "#ff0228a0"
        readonly property color wL_qcells_Primary_900: "#ff001c77"
        readonly property color wL_qcells_Primary_900_12: "#1f001c77"
        readonly property color wL_qcells_Primary_900_24: "#3d001c77"
        readonly property color wL_qcells_Secondary_300: "#ff029a97"
        readonly property color wL_qcells_System_Danger_Dark: "#ff912018"
        readonly property color wL_qcells_System_Danger_Darker: "#ff55160c"
        readonly property color wL_qcells_System_Danger_Light: "#fffecdc9"
        readonly property color wL_qcells_System_Danger_Medium: "#fff97066"
        readonly property color wL_qcells_System_Success_Dark: "#ff085d3a"
        readonly property color wL_qcells_System_Success_Darker: "#ff053321"
        readonly property color wL_qcells_System_Success_Light: "#ffa9efc5"
        readonly property color wL_qcells_System_Success_Medium: "#ff17b26a"
        readonly property color wL_qcells_System_Warning_Dark: "#ff93370d"
        readonly property color wL_qcells_System_Warning_Darker: "#ff4e1d09"
        readonly property color wL_qcells_System_Warning_Light: "#fffedf89"
        readonly property color wL_qcells_System_Warning_Medium: "#fff79009"
    }
}
