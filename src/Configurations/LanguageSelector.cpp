#include "LanguageSelector.h"
#include <QCoreApplication>

LanguageSelector::LanguageSelector(QObject *parent) : QObject(parent)
{
}

void LanguageSelector::changeLanguage(const QString &languageCode)
{
    if (translator.load(":/translations/consolinno-energy." + languageCode + ".qm")) {
        QCoreApplication::installTranslator(&translator);
        m_languageCode = languageCode;
        emit languageChanged();
    }
}
