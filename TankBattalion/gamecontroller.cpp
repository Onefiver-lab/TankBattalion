#include "gamecontroller.h"
#include "settingsmanager.h"
#include <QDebug>

GameController::GameController(QObject *parent)
    : QObject(parent), m_player1(nullptr), m_player2(nullptr),
    m_gameMode(Single), m_difficulty(Easy)
{
    m_gameTimer = new QTimer(this);
    connect(m_gameTimer, &QTimer::timeout, this, &GameController::gameLoop);
    m_mapManager = new MapManager(this);
}

GameController::~GameController() {
    qDeleteAll(m_bulletList);
    qDeleteAll(m_enemyList);
}

void GameController::startGame() {
    m_gameTimer->stop();
    m_elapsedTimer.start();
    m_score = 0;
    emit scoreChanged();

    qDeleteAll(m_bulletList); m_bulletList.clear();
    qDeleteAll(m_enemyList);  m_enemyList.clear();
    if(m_player1) { m_player1->deleteLater(); m_player1 = nullptr; }
    if(m_player2) { m_player2->deleteLater(); m_player2 = nullptr; }

    m_mapManager->loadDefaultMap();
    initSessionRules();

    m_paused = false;
    emit pausedChanged();
    m_gameTimer->start(16);
    emit playersChanged();
    emit enemiesChanged();
    emit bulletsChanged();
}

void GameController::pauseGame() {
    if (m_paused) return;
    if (!m_gameTimer->isActive()) return;
    m_gameTimer->stop();
    m_paused = true;
    emit pausedChanged();
}

void GameController::resumeGame() {
    if (!m_paused) return;
    m_elapsedTimer.start();
    m_gameTimer->start(16);
    m_paused = false;
    emit pausedChanged();
}

void GameController::initSessionRules() {
    int ammoConfig = -1;
    int enemyCount = 0;

    if (m_gameMode != PVP) {
        switch (m_difficulty) {
        case Easy:   enemyCount = 3;  ammoConfig = -1;  break;
        case Medium: enemyCount = 6;  ammoConfig = -1;  break;
        case Hard:   enemyCount = 12; ammoConfig = 100; break;
        case Hell:   enemyCount = 20; ammoConfig = 50;  break;
        }
    }

    if (m_gameMode == Single) {
        m_player1 = new Tank(240, 520, true, 1, this);
        m_player1->setAmmo(ammoConfig);
        spawnEnemies(enemyCount);
    }
    else if (m_gameMode == CoOp) {
        m_player1 = new Tank(240, 520, true, 1, this);
        m_player2 = new Tank(520, 520, true, 2, this);
        m_player1->setAmmo(ammoConfig);
        m_player2->setAmmo(ammoConfig);
        spawnEnemies(enemyCount);
    }
    else if (m_gameMode == PVP) {
        m_player1 = new Tank(40,  520, true, 1, this);
        m_player2 = new Tank(720, 520, true, 2, this);
        m_player1->setAmmo(-1);
        m_player2->setAmmo(-1);
    }
}

void GameController::spawnEnemies(int count) {
    QList<QPointF> spawnPoints = {
        QPointF(40,  0), QPointF(240, 0), QPointF(520, 0), QPointF(720, 0)
};
for (int i = 0; i < count; ++i) {
    QPointF pt = spawnPoints[i % spawnPoints.size()];
    double offsetX = (i / spawnPoints.size()) * 4.0;
    m_enemyList.append(new Tank(pt.x() + offsetX, pt.y(), false, 0, this));
}
}

void GameController::handlePlayerMove(int playerId, int direction, bool moving) {
    if (m_paused) return;
    Tank *target = (playerId == 1) ? m_player1 : m_player2;
    if (target && target->isActive()) {
        target->setDirection(direction);
        target->setMoving(moving);
    }
}

void GameController::handlePlayerFire(int playerId) {
    if (m_paused) return;
    Tank *target = (playerId == 1) ? m_player1 : m_player2;
    if (target && target->isActive()) {
        Bullet *b = target->fire();
        if (b) m_bulletList.append(b);
    }
}

void GameController::gameLoop() {
    if (m_paused) return;

    double deltaTime = m_elapsedTimer.restart() / 1000.0;
    if (deltaTime > 0.05) deltaTime = 0.05;

    if (m_player1 && m_player1->isActive()) {
        QRectF old = m_player1->boundingBox(); m_player1->update(deltaTime);
        if (m_mapManager->checkCollision(m_player1->boundingBox())) {
            m_player1->setX(old.x()); m_player1->setY(old.y());
        }
    }
    if (m_player2 && m_player2->isActive()) {
        QRectF old = m_player2->boundingBox(); m_player2->update(deltaTime);
        if (m_mapManager->checkCollision(m_player2->boundingBox())) {
            m_player2->setX(old.x()); m_player2->setY(old.y());
        }
    }

    for (Tank *enemy : m_enemyList) {
        if (enemy->isActive()) {
            QRectF old = enemy->boundingBox(); enemy->update(deltaTime);
            if (m_mapManager->checkCollision(enemy->boundingBox())) {
                enemy->setX(old.x()); enemy->setY(old.y());
            }
            if (rand() % 100 < 2) {
                Bullet *b = enemy->fire();
                if (b) m_bulletList.append(b);
            }
        }
    }
    for (Bullet *bullet : m_bulletList) bullet->update(deltaTime);

    checkCollisions();
    cleanUpDestroyedObjects();
    emit enemiesChanged();
    emit bulletsChanged();
}

void GameController::checkCollisions() {
    for (Bullet *bullet : m_bulletList) {
        if (!bullet->isActive()) continue;
        if (m_mapManager->handleBulletHit(bullet->boundingBox())) {
            bullet->setActive(false);
            emit explosionRequested(bullet->x() + bullet->boundingBox().width()/2,
                                    bullet->y() + bullet->boundingBox().height()/2, false);
            continue;
        }
        if (bullet->isFromPlayer()) {
            if (m_gameMode != PVP) {
                for (Tank *enemy : m_enemyList) {
                    if (enemy->isActive() && bullet->boundingBox().intersects(enemy->boundingBox())) {
                        bullet->setActive(false);
                        enemy->takeDamage(1);
                        if (!enemy->isActive()) {
                            m_score += 100; emit scoreChanged();
                            emit explosionRequested(enemy->x() + enemy->boundingBox().width()/2,
                                                    enemy->y() + enemy->boundingBox().height()/2, true);
                        }
                        break;
                    }
                }
            } else {
                if (bullet->shooterId() == 1 && m_player2 && m_player2->isActive()) {
                    if (bullet->boundingBox().intersects(m_player2->boundingBox())) {
                        bullet->setActive(false);
                        m_player2->takeDamage(1);
                        emit explosionRequested(m_player2->x() + m_player2->boundingBox().width()/2,
                                                m_player2->y() + m_player2->boundingBox().height()/2, true);
                        if (!m_player2->isActive()) { m_gameTimer->stop(); emit gameOver("玩家 1 斩获胜利！"); }
                    }
                } else if (bullet->shooterId() == 2 && m_player1 && m_player1->isActive()) {
                    if (bullet->boundingBox().intersects(m_player1->boundingBox())) {
                        bullet->setActive(false);
                        m_player1->takeDamage(1);
                        emit explosionRequested(m_player1->x() + m_player1->boundingBox().width()/2,
                                                m_player1->y() + m_player1->boundingBox().height()/2, true);
                        if (!m_player1->isActive()) { m_gameTimer->stop(); emit gameOver("玩家 2 斩获胜利！"); }
                    }
                }
            }
        } else {
            if (m_player1 && m_player1->isActive() && bullet->boundingBox().intersects(m_player1->boundingBox())) {
                bullet->setActive(false); m_player1->takeDamage(1);
                emit explosionRequested(m_player1->x() + m_player1->boundingBox().width()/2,
                                        m_player1->y() + m_player1->boundingBox().height()/2, true);
            }
            if (m_player2 && m_player2->isActive() && bullet->boundingBox().intersects(m_player2->boundingBox())) {
                bullet->setActive(false); m_player2->takeDamage(1);
                emit explosionRequested(m_player2->x() + m_player2->boundingBox().width()/2,
                                        m_player2->y() + m_player2->boundingBox().height()/2, true);
            }
            if (m_gameMode == Single && m_player1 && !m_player1->isActive()) {
                m_gameTimer->stop();
                emit gameOver("全军覆没，游戏失败！");
            } else if (m_gameMode == CoOp) {
                bool p1Dead = !m_player1 || !m_player1->isActive();
                bool p2Dead = !m_player2 || !m_player2->isActive();
                if (p1Dead && p2Dead) { m_gameTimer->stop(); emit gameOver("两位玩家均已阵亡，游戏失败！"); }
            }
        }
    }

    if (m_gameMode != PVP && m_enemyList.isEmpty() && m_gameTimer->isActive()) {
        m_gameTimer->stop();
        emit gameOver("恭喜通关，击碎了所有敌军坦克！");
    }
}

void GameController::cleanUpDestroyedObjects() {
    auto bit = m_bulletList.begin();
    while (bit != m_bulletList.end()) {
        if (!(*bit)->isActive()) { (*bit)->deleteLater(); bit = m_bulletList.erase(bit); }
        else ++bit;
    }
    auto tit = m_enemyList.begin();
    while (tit != m_enemyList.end()) {
        if (!(*tit)->isActive()) { (*tit)->deleteLater(); tit = m_enemyList.erase(tit); }
        else ++tit;
    }
}

QList<QObject*> GameController::bullets() const {
    QList<QObject*> list; for (auto b : m_bulletList) list.append(b); return list;
}
QList<QObject*> GameController::enemies() const {
    QList<QObject*> list; for (auto e : m_enemyList) list.append(e); return list;
}

QVariantMap GameController::captureSnapshot() const {
    QVariantMap snap;
    snap["gameMode"]   = m_gameMode;
    snap["difficulty"] = m_difficulty;
    snap["score"]      = m_score;

    QVariantList map;
    for (int r = 0; r < MapManager::ROWS; ++r)
        for (int c = 0; c < MapManager::COLS; ++c)
            map.append(m_mapManager->getTileType(r, c));
    snap["map"] = map;

    auto tankToMap = [](const Tank *t) -> QVariantMap {
        QVariantMap m;
        if (!t) return m;
        m["x"] = t->x(); m["y"] = t->y();
        m["dir"] = t->direction();
        m["hp"] = t->hp();
        m["ammo"] = t->ammo();
        m["active"] = t->isActive();
        return m;
    };
    snap["p1"] = tankToMap(m_player1);
    snap["p2"] = tankToMap(m_player2);

    QVariantList enemies;
    for (Tank *e : m_enemyList) {
        QVariantMap m = tankToMap(e);
        m["active"] = e->isActive();
        enemies.append(m);
    }
    snap["enemies"] = enemies;

    QVariantList bullets;
    for (Bullet *b : m_bulletList) {
        QVariantMap m;
        m["x"] = b->x(); m["y"] = b->y();
        m["dir"] = b->direction();
        m["fromPlayer"] = b->isFromPlayer();
        m["shooterId"] = b->shooterId();
        bullets.append(m);
    }
    snap["bullets"] = bullets;

    QString modeName = (m_gameMode == Single) ? QStringLiteral("单人")
                       : (m_gameMode == CoOp)   ? QStringLiteral("双人")
                                              :                          QStringLiteral("PVP");
    QString diffName = (m_difficulty == Easy)   ? QStringLiteral("简单")
                       : (m_difficulty == Medium) ? QStringLiteral("中等")
                       : (m_difficulty == Hard)   ? QStringLiteral("困难")
                                                  :                            QStringLiteral("地狱");
    snap["summary"] = QStringLiteral("%1 · %2 · %3 分 · 剩余 %4 敌")
                          .arg(modeName, diffName).arg(m_score).arg(m_enemyList.size());
    return snap;
}

bool GameController::restoreSnapshot(const QVariantMap &snap) {
    if (snap.isEmpty()) return false;
    m_gameTimer->stop();

    m_gameMode   = snap.value("gameMode", Single).toInt();
    m_difficulty = snap.value("difficulty", Easy).toInt();
    m_score      = snap.value("score", 0).toInt();
    emit gameModeChanged();
    emit difficultyChanged();
    emit scoreChanged();

    qDeleteAll(m_bulletList); m_bulletList.clear();
    qDeleteAll(m_enemyList);  m_enemyList.clear();
    if (m_player1) { m_player1->deleteLater(); m_player1 = nullptr; }
    if (m_player2) { m_player2->deleteLater(); m_player2 = nullptr; }

    const QVariantList map = snap.value("map").toList();
    for (int r = 0; r < MapManager::ROWS && r * MapManager::COLS < map.size(); ++r) {
        for (int c = 0; c < MapManager::COLS; ++c) {
            int idx = r * MapManager::COLS + c;
            if (idx < map.size()) m_mapManager->setTileType(r, c, map.at(idx).toInt());
        }
    }

    auto spawnTankFromMap = [&](const QVariantMap &m, bool isPlayer, int pid) -> Tank* {
        if (m.isEmpty()) return nullptr;
        Tank *t = new Tank(m.value("x", 0).toDouble(), m.value("y", 0).toDouble(),
                           isPlayer, pid, this);
        t->setDirection(m.value("dir", 0).toInt());
        t->setAmmo(m.value("ammo", -1).toInt());
        int hp = m.value("hp", 1).toInt();
        int dmg = t->maxHp() - hp;
        for (int i = 0; i < dmg && t->isActive(); ++i) t->takeDamage(1);
        if (!m.value("active", true).toBool()) t->setActive(false);
        return t;
    };

    m_player1 = spawnTankFromMap(snap.value("p1").toMap(), true, 1);
    m_player2 = spawnTankFromMap(snap.value("p2").toMap(), true, 2);

    const QVariantList enemies = snap.value("enemies").toList();
    for (const QVariant &v : enemies) {
        Tank *t = spawnTankFromMap(v.toMap(), false, 0);
        if (t) m_enemyList.append(t);
    }
    const QVariantList bullets = snap.value("bullets").toList();
    for (const QVariant &v : bullets) {
        QVariantMap m = v.toMap();
        Bullet *b = new Bullet(m.value("x", 0).toDouble(), m.value("y", 0).toDouble(),
                               m.value("dir", 0).toInt(),
                               m.value("fromPlayer", false).toBool(),
                               m.value("shooterId", 0).toInt(), this);
        m_bulletList.append(b);
    }

    m_paused = false;
    emit pausedChanged();
    emit playersChanged();
    emit enemiesChanged();
    emit bulletsChanged();
    m_elapsedTimer.start();
    m_gameTimer->start(16);
    return true;
}

void GameController::reportFinalScore() {
    if (!m_settings) return;
    m_settings->reportScore(m_gameMode, m_difficulty, m_score);
}