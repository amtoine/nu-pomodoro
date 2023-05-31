export-env {
    reset
}

export module pomodoro {
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
        print $env.nu-pomodoro
    }

    export def-env reset [] {
        $env.nu-pomodoro = {
            pomodoros: 0
            breaks: 0
            total-time: 0min
        }
    }
}
