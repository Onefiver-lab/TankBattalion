#include "bullet.h"

Bullet::Bullet(double x, double y, int direction, bool isFromPlayer, QObject *parent)
    : GameObject(x, y, 8, 8, parent), m_isFromPlayer(isFromPlayer)
{
    m_direction = direction;
    m_speed = 300.0;
}

void Bullet::update(double deltaTime) {
    if (!m_active) return;


    switch (m_direction) {
    case Up:    setY(m_y - m_speed * deltaTime); break;
    case Down:  setY(m_y + m_speed * deltaTime); break;
    case Left:  setX(m_x - m_speed * deltaTime); break;
    case Right: setX(m_x + m_speed * deltaTime); break;
    }


    if (m_x < 0 || m_x > 800 || m_y < 0 || m_y > 600) {
        setActive(false);
    }
}