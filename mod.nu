export module pomodoro {
    def check-pomodoro [] {
        not ($env.nu-pomodoro? | is-empty)
    }

    def no-pomodoro-error [] {
        error make --unspanned {
            msg: $"no (ansi default_italic)pomodoro(ansi reset) started, please run ('pomodoro start' | nu-highlight)."
        }
    }

    def chrono [
        pomodoro: record<
            length: duration
            title: string
            text: string
        >
    ] {
        termdown --no-seconds --blink --end $"($pomodoro.length)" --title $pomodoro.title --text $pomodoro.text
    }
    export def-env work [
        --length: duration = 25min
    ] {
        if not (check-pomodoro) {
            no-pomodoro-error
        }

        chrono {
            length: $length
            title: "Pomodoro"
            text: "Time for a break"
        }

        $env.nu-pomodoro.pomodoros += 1
        $env.nu-pomodoro.total-time += $length
    }

    export def-env break [
        --length: duration
        --long: bool
    ] {
        if not (check-pomodoro) {
            no-pomodoro-error
        }

        let length = if $length == null {
            if $long { 15min } else { 5min }
        } else {
            $length
        }

        chrono {
            length: $length
            title: (if $long { "Long break" } else { "Little break" })
            text: "Time to go back to work"
        }

        $env.nu-pomodoro.breaks += 1
        $env.nu-pomodoro.total-time += $length
    }

    export def status [] {
        if not (check-pomodoro) {
            no-pomodoro-error
        }

        print $env.nu-pomodoro
    }

    export def-env start [
        --force: bool
    ] {
        if (not (check-pomodoro)) or $force {
            $env.nu-pomodoro = {
                pomodoros: 0
                breaks: 0
                total-time: 0min
            }
            return
        }

        error make --unspanned {
            msg: $"a (ansi default_italic)pomodoro(ansi reset) has already started, please use the ('--force' | nu-highlight) option."
        }
    }
}
