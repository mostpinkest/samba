#! /usr/bin/env python3

import sys
import subprocess


def write_stdout(s):
    # only eventlistener protocol messages may be sent to stdout
    sys.stdout.write(s)
    sys.stdout.flush()


def write_stderr(s):
    sys.stderr.write(s)
    sys.stderr.flush()


def parse_line(line):
    return dict([x.split(':') for x in line.split()])


def main():
    while 1:
        # transition from ACKNOWLEDGED to READY
        write_stdout('READY\n')

        # read header line and print it to stderr
        line = sys.stdin.readline()
        try:
            # read event payload and print it to stderr
            headers = parse_line(line)
            data = parse_line(sys.stdin.read(int(headers['len'])))
            # write_stderr("\n")
            # write_stderr(line)
            # write_stderr(data)

            if headers["eventname"] == "PROCESS_STATE_RUNNING" and \
                data["processname"] == "samba_statusd":
                subprocess.run(["supervisorctl", "-c", "/etc/supervisor/conf.d/supervisord.conf",
                                "start", "samba_exporter"], stdout=sys.stderr.buffer, check=True)
            elif headers["eventname"] == "PROCESS_STATE_STOPPING" and \
                data["processname"] == "samba_statusd":
                subprocess.run(
                    ["supervisorctl", "-c", "/etc/supervisor/conf.d/supervisord.conf", "stop",
                     "samba_exporter"], stdout=sys.stderr.buffer, check=True)

            # transition from READY to ACKNOWLEDGED
            write_stdout('RESULT 2\nOK')
        except Exception as e:
            write_stderr(e)

            # return FAIL on error
            write_stdout('RESULT 4\nFAIL')


if __name__ == '__main__':
    main()
