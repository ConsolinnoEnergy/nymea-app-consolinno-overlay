#ifndef LANGUAGESELECTOR_H
#define LANGUAGESELECTOR_H

#include <QObject>
#include <QTranslator>

class LanguageSelector : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString languageCode READ languageCode NOTIFY languageChanged)

public:
    explicit LanguageSelector(QObject *parent = nullptr);

    Q_INVOKABLE void changeLanguage(const QString &languageCode);

    QString languageCode() const { return m_languageCode; }

signals:
    void languageChanged();

private:
    QTranslator translator;
    QString m_languageCode;
};

#endif // LANGUAGESELECTOR_H
