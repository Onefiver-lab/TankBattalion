

#pragma once
#include <QObject>
#include <QRectF>

class GameObject : public QObject {
    Q_OBJECT
    Q_PROPERTY(double x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(double y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(int direction READ direction WRITE setDirection NOTIFY directionChanged)
    Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)

public:
    enum Direction { Up = 0, Down, Left, Right };
    Q_ENUM(Direction)

    GameObject(double x, double y, double width, double height, QObject *parent = nullptr);
    virtual ~GameObject() = default;

    virtual void update(double deltaTime) = 0;

    virtual QRectF boundingBox() const;

    double x() const { return m_x; }
    double y() const { return m_y; }
    int direction() const { return m_direction; }
    bool isActive() const { return m_active; }

    void setX(double x);
    void setY(double y);
    void setDirection(int dir);
    void setActive(bool active);

signals:
    void xChanged();
    void yChanged();
    void directionChanged();
    void activeChanged();

protected:
    double m_x;
    double m_y;
    double m_width;
    double m_height;
    int m_direction;
    double m_speed;
    bool m_active;
};