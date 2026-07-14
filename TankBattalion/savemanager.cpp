#include "savemanager.h"
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>

SaveManager::SaveManager(QObject *parent) : QObject(parent) {
    refreshFromDisk();
}

QString SaveManager::filePath() const {
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    return dir + QStringLiteral("/savegame.json");
}

void SaveManager::refreshFromDisk() {
    QFile f(filePath());
    m_hasSave = false;
    m_savedAt.clear();
    m_summary.clear();
    if (!f.exists()) { emit saveStateChanged(); return; }
    if (!f.open(QIODevice::ReadOnly)) { emit saveStateChanged(); return; }
    const QByteArray bytes = f.readAll();
    f.close();
    const QJsonDocument doc = QJsonDocument::fromJson(bytes);
    if (!doc.isObject()) { emit saveStateChanged(); return; }
    const QJsonObject obj = doc.object();
    m_hasSave = obj.value("hasSave").toBool(true);
    m_savedAt = obj.value("savedAt").toString();
    m_summary = obj.value("summary").toString();
    emit saveStateChanged();
}

bool SaveManager::writeSnapshot(const QVariantMap &snapshot) {
    QJsonObject root;
    root["hasSave"]  = true;
    root["savedAt"]  = QDateTime::currentDateTime().toString(Qt::ISODate);
    root["summary"]  = snapshot.value("summary").toString();
    root["payload"]  = QJsonValue::fromVariant(snapshot);

    QFile f(filePath());
    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) return false;
    f.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    f.close();

    refreshFromDisk();
    return true;
}

QVariantMap SaveManager::readSnapshot() const {
    QFile f(filePath());
    if (!f.open(QIODevice::ReadOnly)) return {};
    const QByteArray bytes = f.readAll();
    f.close();
    const QJsonDocument doc = QJsonDocument::fromJson(bytes);
    if (!doc.isObject()) return {};
    return doc.object().value("payload").toObject().toVariantMap();
}

void SaveManager::clear() {
    QFile::remove(filePath());
    refreshFromDisk();
}
