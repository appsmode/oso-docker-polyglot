# Check POLAR_LOG behaviour in different Languages supported by Oso

from typing import List
from dataclasses import dataclass
import logging
import pytest
from subprocess import run, PIPE, STDOUT
import os
import sys

logging.basicConfig(level=logging.INFO)


@dataclass(frozen=True)
class Repl:
    language: str
    run_function: List[str]


REPL_QUERY = """1+2=3
"""
# After defining the variables we will execute the code that is found in part 2 of the tutorial
REPLS: List[Repl] = [
    Repl(language="go", run_function=["oso"]),
    Repl(language="java", run_function=["make", "repl"]),
    Repl(language="js", run_function=["/usr/bin/oso"]),
    Repl(language="python", run_function=["python", "-m", "oso"]),
    Repl(language="ruby", run_function=["bundle", "exec", "oso"]),
    Repl(language="rust", run_function=["cargo", "run", "--features=cli"]),
]


def polar_log_repl(log_level: str, language: str, new_env: dict, repl: List[str]):
    if log_level:
        new_env["POLAR_LOG"] = log_level
    output = run(
        repl, env=new_env, input=REPL_QUERY, capture_output=True, text=True, check=True
    )
    return output


@pytest.mark.parametrize("repl", [repl for repl in REPLS])
@pytest.mark.parametrize(
    "log_level,stdout_trace_expected,stderr_trace_expected",
    [
        ("1", True, False),
        ("0", False, False),
        ("foo", True, False),
        ("off", False, False),
        ("now", False, True),
        (None, False, False),
        ("foo1", True, False),
    ],
)
def test_app(
    repl: Repl, log_level: str, stdout_trace_expected: bool, stderr_trace_expected: bool
):
    print(
        f"Testing {repl.language} POLAR_LOG={log_level} stdout_trace_expected={stdout_trace_expected} stderr_trace_expected={stderr_trace_expected}"
    )
    startdir = os.environ["OSO_GIT_HOME"]
    os.chdir(f"{startdir}/languages")
    os.chdir(repl.language)
    new_env = os.environ.copy()
    # ensure we prefer the executable in the current directory
    new_env["PATH"] = ".:" + new_env["PATH"]
    try:
        output = polar_log_repl(
            log_level=log_level,
            language=repl.language,
            new_env=new_env,
            repl=repl.run_function,
        )
        print("stdout: " + output.stdout)
        print("stderr: " + output.stderr)
        if stdout_trace_expected:
            assert "[debug]" in output.stdout
        else:
            assert not "[debug]" in output.stdout
        if stderr_trace_expected:
            assert "[debug]" in output.stderr
        else:
            assert not "[debug]" in output.stderr
    except OSError as e:
        print("Execution failed:", e, file=sys.stderr)
        pytest.fail(e)
    os.chdir(startdir)
