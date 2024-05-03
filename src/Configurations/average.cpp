#include "average.h"


Average::Average(QObject *parent): QObject(parent)
{
    // insert a init value
    // m_window.push(0);
}


double Average::value() const
{
    return m_value;
}

int Average::windowSize() const
{
    return m_windowSize;
}

void Average::setWindowSize(int size)
{
    m_windowSize = size;
}

void Average::next(double val) 
{
    if (m_window.size() == m_windowSize) {
        m_sum -= m_window.front();
        m_window.pop();
    }
    m_sum += val;
    m_window.push(val);

    m_value = m_sum / m_window.size();
}