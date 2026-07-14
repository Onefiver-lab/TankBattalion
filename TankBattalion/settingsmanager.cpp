#include "settingsmanager.h"
#include <QSettings>
#include <QCoreApplication>

namespace {
    constexpr const char *kSoundEnabled = "audio/soundEnabled";
    constexpr const char *kSoundVolume  = "audio/soundVolume";
    constexpr const char *kFullscreen   = "ui/fullscreen";
    constexpr const char *kBestPrefix   = "score/best";
}

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent),
    m_settings(new QSettings(QSettings::IniFormat,
                             QSettings::UserScope,
                             QStringLiteral("TankBattalion"),
                             QStringLiteral("TankBattalion"),
                             this))
{
    if (!m_settings->contains(kSoundEnabled))
        m_settings->setValue(kSoundEnabled, true);
    if (!m_settings->contains(kSoundVolume))
        m_settings->setValue(kSoundVolume, 70);
    if (!m_settings->contains(kFullscreen))
        m_settings->setValue(kFullscreen, false);
}

SettingsManager::~SettingsManager() = default;

bool SettingsManager::soundEnabled() const {
    return m_settings->value(kSoundEnabled, true).toBool();
}
void SettingsManager::setSoundEnabled(bool on) {
    if (soundEnabled() == on) return;
    m_settings->setValue(kSoundEnabled, on);
    emit soundEnabledChanged();
}

int SettingsManager::soundVolume() const {
    return m_settings->value(kSoundVolume, 70).toInt();
}
void SettingsManager::setSoundVolume(int v) {
    v = qBound(0, v, 100);
    if (soundVolume() == v) return;
    m_settings->setValue(kSoundVolume, v);
    emit soundVolumeChanged();
}

bool SettingsManager::fullscreen() const {
    return m_settings->value(kFullscreen, false).toBool();
}
void SettingsManager::setFullscreen(bool on) {
    if (fullscreen() == on) return;
    m_settings->setValue(kFullscreen, on);
    emit fullscreenChanged();
}

int SettingsManager::bestScore() const {
    int best = 0;
    for (int m = 0; m < 3; ++m)
        for (int d = 0; d < 4; ++d)
            best = qMax(best, bestScoreFor(m, d));
    return best;
}

int SettingsManager::bestScoreFor(int gameMode, int difficulty) const {
    const QString key = QStringLiteral("%1/%2/%3")
    .arg(QString::fromLatin1(kBestPrefix))
        .arg(gameMode)
        .arg(difficulty);
    return m_settings->value(key, 0).toInt();
}

void SettingsManager::reportScore(int gameMode, int difficulty, int score) {
    if (score <= 0) return;
    const QString key = QStringLiteral("%1/%2/%3")
                            .arg(QString::fromLatin1(kBestPrefix))
                            .arg(gameMode)
                            .arg(difficulty);
    const int prev = m_settings->value(key, 0).toInt();
    if (score > prev) {
        m_settings->setValue(key, score);
        m_settings->sync();
        emit bestScoreChanged();
    }
}

void SettingsManager::clearAll() {
    m_settings->clear();
    m_settings->sync();
    emit soundEnabledChanged();
    emit soundVolumeChanged();
    emit fullscreenChanged();
    emit bestScoreChanged();
}
