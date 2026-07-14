#pragma once
#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>

class QSettings;

class SettingsManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool soundEnabled READ soundEnabled WRITE setSoundEnabled NOTIFY soundEnabledChanged)
    Q_PROPERTY(int  soundVolume  READ soundVolume  WRITE setSoundVolume  NOTIFY soundVolumeChanged)
    Q_PROPERTY(bool fullscreen   READ fullscreen   WRITE setFullscreen   NOTIFY fullscreenChanged)
    Q_PROPERTY(int  bestScore    READ bestScore    NOTIFY bestScoreChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);
    ~SettingsManager();

    bool soundEnabled() const;
    void setSoundEnabled(bool on);

    int  soundVolume() const;
    void setSoundVolume(int v);

    bool fullscreen() const;
    void setFullscreen(bool on);

    int  bestScore() const;

    Q_INVOKABLE void reportScore(int gameMode, int difficulty, int score);
    Q_INVOKABLE int  bestScoreFor(int gameMode, int difficulty) const;
    Q_INVOKABLE void clearAll();

signals:
    void soundEnabledChanged();
    void soundVolumeChanged();
    void fullscreenChanged();
    void bestScoreChanged();

private:
    QSettings *m_settings;

    QML_ELEMENT
};