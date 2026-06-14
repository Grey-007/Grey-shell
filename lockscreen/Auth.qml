pragma Singleton
import Quickshell
import Quickshell.Services.Pam

// ─────────────────────────────────────────────────────────────────────────
// reader-shell · Auth
//
// Thin wrapper around PamContext (Quickshell.Services.Pam) that exposes a
// simple authenticate(password) call plus unlocked()/failed() signals.
// Shared as a singleton so every monitor's lock surface drives the same
// authentication state (and only one PAM conversation runs at a time).
// ─────────────────────────────────────────────────────────────────────────
Singleton {
    id: root

    signal unlocked()
    signal failed()

    // True while a PAM conversation is in progress — used to disable the
    // input field and show a small "checking..." state.
    property bool unlocking: false

    // The password currently being checked. Cleared as soon as PAM
    // consumes it.
    property string _pending: ""

    function authenticate(password) {
        if (root.unlocking || password.length === 0)
            return;

        root._pending = password;
        root.unlocking = true;
        pam.start();
    }

    PamContext {
        id: pam

        // PAM is asking us for something (almost always "Password: ").
        // Hand back whatever the user typed.
        onPamMessage: {
            if (pam.responseRequired)
                pam.respond(root._pending);
        }

        // The PAM conversation has finished — either success or failure.
        onCompleted: result => {
            root.unlocking = false;
            root._pending = "";

            if (result === PamResult.Success)
                root.unlocked();
            else
                root.failed();
        }
    }
}
