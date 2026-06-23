#include "gameobject.h"

GameObject::GameObject(double x, double y, double width, double height, QObject *parent)
    : QObject(parent), m_x(x), m_y(y), m_width(width), m_height(height),
    m_direction(Up), m_speed(0.0), m_active(true) {}

QRectF GameObject::boundingBox() const {
    return QRectF(m_x, m_y, m_width, m_height);
}

void GameObject::setX(double x) {
    if (qFuzzyCompare(m_x, x)) return;
    m_x = x;
    emit xChanged();
}

void GameObject::setY(double y) {
    if (qFuzzyCompare(m_y, y)) return;
    m_y = y;
    emit yChanged();
}

void GameObject::setDirection(int dir) {
    if (m_direction == dir) return;
    m_direction = dir;
    emit directionChanged();
}

void GameObject::setActive(bool active) {
    if (m_active == active) return;
    m_active = active;
    emit activeChanged();
}