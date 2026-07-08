#include "gamecontroller.h"
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

    qDeleteAll(m_bulletList); m_bulletList.clear();
    qDeleteAll(m_enemyList);  m_enemyList.clear();
    if(m_player1) { m_player1->deleteLater(); m_player1 = nullptr; }
    if(m_player2) { m_player2->deleteLater(); m_player2 = nullptr; }

    m_mapManager->loadDefaultMap();
    initSessionRules();

    m_gameTimer->start(16);
    emit playersChanged();
    emit enemiesChanged();
    emit bulletsChanged();
}

void GameController::pauseGame() {
    m_gameTimer->stop();
}

void GameController::initSessionRules() {
    int ammoConfig = -1;
    int enemyCount = 0;

    if (m_gameMode != PVP) {
        switch (m_difficulty) {
        case Easy:   enemyCount = 3;  ammoConfig = -1;  break;
        case Medium:  enemyCount = 6;  ammoConfig = -1;  break;
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
        QPointF(40,  0),
        QPointF(240, 0),
        QPointF(520, 0),
        QPointF(720, 0)
    };

    for (int i = 0; i < count; ++i) {
        QPointF pt = spawnPoints[i % spawnPoints.size()];
        double offsetX = (i / spawnPoints.size()) * 4.0;
        m_enemyList.append(new Tank(pt.x() + offsetX, pt.y(), false, 0, this));
    }
}

void GameController::handlePlayerMove(int playerId, int direction, bool moving) {
    Tank *target = (playerId == 1) ? m_player1 : m_player2;
    if (target && target->isActive()) {
        target->setDirection(direction);
        target->setMoving(moving);
    }
}

void GameController::handlePlayerFire(int playerId) {
    Tank *target = (playerId == 1) ? m_player1 : m_player2;
    if (target && target->isActive()) {
        Bullet *b = target->fire();
        if (b) m_bulletList.append(b);
    }
}

void GameController::gameLoop() {
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
            continue;
        }

        if (bullet->isFromPlayer()) {
            if (m_gameMode != PVP) {
                for (Tank *enemy : m_enemyList) {
                    if (enemy->isActive() && bullet->boundingBox().intersects(enemy->boundingBox())) {
                        bullet->setActive(false);
                        enemy->takeDamage(1);
                        break;
                    }
                }
            }
            else {
                if (bullet->shooterId() == 1 && m_player2 && m_player2->isActive()) {
                    if (bullet->boundingBox().intersects(m_player2->boundingBox())) {
                        bullet->setActive(false);
                        m_player2->takeDamage(1);
                        if (!m_player2->isActive()) {
                            m_gameTimer->stop();
                            emit gameOver("玩家 1 斩获胜利！");
                        }
                    }
                }
                else if (bullet->shooterId() == 2 && m_player1 && m_player1->isActive()) {
                    if (bullet->boundingBox().intersects(m_player1->boundingBox())) {
                        bullet->setActive(false);
                        m_player1->takeDamage(1);
                        if (!m_player1->isActive()) {
                            m_gameTimer->stop();
                            emit gameOver("玩家 2 斩获胜利！");
                        }
                    }
                }
            }
        }
        else {
            if (m_player1 && m_player1->isActive() && bullet->boundingBox().intersects(m_player1->boundingBox())) {
                bullet->setActive(false);
                m_player1->takeDamage(1);
            }
            if (m_player2 && m_player2->isActive() && bullet->boundingBox().intersects(m_player2->boundingBox())) {
                bullet->setActive(false);
                m_player2->takeDamage(1);
            }

            if (m_gameMode == Single && m_player1 && !m_player1->isActive()) {
                m_gameTimer->stop();
                emit gameOver("全军覆没，游戏失败！");
            }
            else if (m_gameMode == CoOp) {
                bool p1Dead = !m_player1 || !m_player1->isActive();
                bool p2Dead = !m_player2 || !m_player2->isActive();
                if (p1Dead && p2Dead) {
                    m_gameTimer->stop();
                    emit gameOver("两位玩家均已阵亡，游戏失败！");
                }
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