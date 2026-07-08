#include "gameobject.h"

GameObject::GameObject(double x, double y, double width, double height, QObject *parent)
    : QObject(parent), m_x(x), m_y(y), m_width(width), m_height(height),
    m_direction(Up), m_speed(0.0), m_active(true)
{
}

QRectF GameObject::boundingBox() const {
    return QRectF(m_x, m_y, m_width, m_height);
}

double GameObject::x() const {
    return m_x;
}

double GameObject::y() const {
    return m_y;
}

int GameObject::direction() const {
    return m_direction;
}

bool GameObject::isActive() const {
    return m_active;
}

void GameObject::setX(double x) {
    if (!qFuzzyCompare(m_x, x)) {
        m_x = x;
        emit xChanged();
    }
}

void GameObject::setY(double y) {
    if (!qFuzzyCompare(m_y, y)) {
        m_y = y;
        emit yChanged();
    }
}

void GameObject::setDirection(int dir) {
    if (m_direction != dir) {
        m_direction = dir;
        emit directionChanged();
    }
}

void GameObject::setActive(bool active) {
    if (m_active != active) {
        m_active = active;
        emit activeChanged();
    }
}