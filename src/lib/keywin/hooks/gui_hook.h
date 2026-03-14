#pragma once

#include <QString>

class QCheckBox;
class QDialog;
class QMainWindow;
class QRadioButton;
class AppConfig;

namespace deskflow::gui {
class CoreProcess;
}

namespace synergy::hooks {

inline void onMainWindow(QMainWindow *, AppConfig *, deskflow::gui::CoreProcess *) {}

inline bool onAppStart()
{
  return true;
}

inline void onSettings(QDialog *, QCheckBox *, QCheckBox *, QRadioButton *, QRadioButton *) {}

inline void onVersionCheck(QString &) {}

inline bool onCoreStart()
{
  return true;
}

inline void onTestStart() {}

} // namespace synergy::hooks
