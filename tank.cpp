#include "tank.h"
#include "bullet.h"
#include <QRandomGenerator>

Tank::Tank(double x, double y, bool isPlayer, QObject *parent)
    : GameObject(x, y, 40, 40, parent),
    m_isPlayer(isPlayer), m_isMoving(false),
    m_aiDecisionTimer(0.0), m_aiFireTimer(0.0)
{
    if (m_isPlayer) {
        m_maxHp = 3;
        m_speed = 150.0;
    } else {
        m_maxHp = 1;
        m_speed = 100.0;
        m_isMoving = true;
        m_direction = Down;
    }
    m_hp = m_maxHp;
}

void Tank::takeDamage(int amount) {
    if (!m_active) return;
    m_hp -= amount;
    emit hpChanged();
    if (m_hp <= 0) {
        m_hp = 0;
        setActive(false);
    }
}

Bullet* Tank::fire() {
    if (!m_active) return nullptr;

    double bulletX = m_x + m_width / 2.0 - 4;
    double bulletY = m_y + m_height / 2.0 - 4;

    switch (m_direction) {
    case Up:    bulletY = m_y - 8; break;
    case Down:  bulletY = m_y + m_height; break;
    case Left:  bulletX = m_x - 8; break;
    case Right: bulletX = m_x + m_width; break;
    }

    return new Bullet(bulletX, bulletY, m_direction, m_isPlayer, parent());
}

void Tank::update(double deltaTime) {
    if (!m_active) return;

    if (!m_isPlayer) {
        updateAI(deltaTime);
    }

    if (m_isMoving) {
        switch (m_direction) {
        case Up:    setY(m_y - m_speed * deltaTime); break;
        case Down:  setY(m_y + m_speed * deltaTime); break;
        case Left:  setX(m_x - m_speed * deltaTime); break;
        case Right: setX(m_x + m_speed * deltaTime); break;
        }

        if (m_x < 0) setX(0);
        if (m_x > 800 - m_width) setX(800 - m_width);
        if (m_y < 0) setY(0);
        if (m_y > 600 - m_height) setY(600 - m_height);
    }
}

void Tank::updateAI(double deltaTime) {
    m_aiDecisionTimer -= deltaTime;
    if (m_aiDecisionTimer <= 0) {
        m_direction = QRandomGenerator::global()->bounded(0, 4);
        double randomFactor = QRandomGenerator::global()->generateDouble(); // 0.0 ~ 1.0
        m_aiDecisionTimer = 1.5 + randomFactor * (3.0 - 1.5);
    }

    m_aiFireTimer -= deltaTime;
    if (m_aiFireTimer <= 0) {
        double randomFactor = QRandomGenerator::global()->generateDouble(); // 0.0 ~ 1.0
        m_aiFireTimer = 1.0 + randomFactor * (2.5 - 1.0);
    }
}