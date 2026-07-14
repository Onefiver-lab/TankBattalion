#pragma once
#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QtQmlIntegration/qqmlintegration.h>

class SaveManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool    hasSave   READ hasSave   NOTIFY saveStateChanged)
    Q_PROPERTY(QString savedAt   READ savedAt   NOTIFY saveStateChanged)
    Q_PROPERTY(QString summary   READ summary   NOTIFY saveStateChanged)

public:
    explicit SaveManager(QObject *parent = nullptr);

    bool    hasSave() const   { return m_hasSave; }
    QString savedAt() const   { return m_savedAt; }
    QString summary() const   { return m_summary; }

    Q_INVOKABLE bool writeSnapshot(const QVariantMap &snapshot);
    Q_INVOKABLE QVariantMap readSnapshot() const;
    Q_INVOKABLE void clear();

signals:
    void saveStateChanged();

private:
    QString filePath() const;
    void    refreshFromDisk();

    bool    m_hasSave   = false;
    QString m_savedAt;
    QString m_summary;

    QML_ELEMENT
};