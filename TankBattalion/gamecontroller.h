#pragma once
#include <QObject>
#include <QTimer>
#include <QElapsedTimer>
#include <QList>
#include <QVariantMap>
#include <QtQmlIntegration/qqmlintegration.h>
#include "bullet.h"
#include "tank.h"
#include "mapmanager.h"

class GameController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> bullets READ bullets NOTIFY bulletsChanged)
    Q_PROPERTY(QList<QObject*> enemies READ enemies NOTIFY enemiesChanged)
    Q_PROPERTY(Tank* player1 READ player1 NOTIFY playersChanged)
    Q_PROPERTY(Tank* player2 READ player2 NOTIFY playersChanged)
    Q_PROPERTY(MapManager* mapManager READ mapManager CONSTANT)

    Q_PROPERTY(int gameMode READ gameMode WRITE setGameMode NOTIFY gameModeChanged)
    Q_PROPERTY(int difficulty READ difficulty WRITE setDifficulty NOTIFY difficultyChanged)
    Q_PROPERTY(bool paused READ paused NOTIFY pausedChanged)
    Q_PROPERTY(int currentScore READ currentScore NOTIFY scoreChanged)

public:
    enum GameMode { Single = 0, CoOp, PVP };
    Q_ENUM(GameMode)
    enum Difficulty { Easy = 0, Medium, Hard, Hell };
    Q_ENUM(Difficulty)

    explicit GameController(QObject *parent = nullptr);
    ~GameController();

    Q_INVOKABLE void startGame();
    Q_INVOKABLE void pauseGame();
    Q_INVOKABLE void resumeGame();
    Q_INVOKABLE void handlePlayerMove(int playerId, int direction, bool moving);
    Q_INVOKABLE void handlePlayerFire(int playerId);

    bool paused() const { return m_paused; }

    Q_INVOKABLE QVariantMap captureSnapshot() const;
    Q_INVOKABLE bool        restoreSnapshot(const QVariantMap &snap);

    int currentScore() const { return m_score; }

    Q_INVOKABLE void reportFinalScore();

    QList<QObject*> bullets() const;
    QList<QObject*> enemies() const;
    Tank* player1() const { return m_player1; }
    Tank* player2() const { return m_player2; }
    MapManager* mapManager() const { return m_mapManager; }

    int gameMode() const { return m_gameMode; }
    void setGameMode(int mode) { if(m_gameMode != mode) { m_gameMode = mode; emit gameModeChanged(); } }

    int difficulty() const { return m_difficulty; }
    void setDifficulty(int diff) { if(m_difficulty != diff) { m_difficulty = diff; emit difficultyChanged(); } }

    void setSettingsManager(class SettingsManager *s) { m_settings = s; }

signals:
    void gameOver(QString message);
    void bulletsChanged();
    void enemiesChanged();
    void playersChanged();
    void gameModeChanged();
    void difficultyChanged();
    void pausedChanged();
    void scoreChanged();
    void explosionRequested(double x, double y, bool isBig);

private slots:
    void gameLoop();

private:
    void initSessionRules();
    void spawnEnemies(int count);
    void checkCollisions();
    void cleanUpDestroyedObjects();

    QTimer *m_gameTimer;
    QElapsedTimer m_elapsedTimer;

    QList<Bullet*> m_bulletList;
    QList<Tank*> m_enemyList;
    Tank *m_player1;
    Tank *m_player2;
    MapManager *m_mapManager;
    SettingsManager *m_settings = nullptr;

    int m_gameMode;
    int m_difficulty;
    bool m_paused = false;
    int  m_score = 0;

    QML_ELEMENT
};