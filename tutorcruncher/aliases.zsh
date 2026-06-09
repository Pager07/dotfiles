# Django Shortcuts
alias src="source env/bin/activate"
rs() { pkill -f 'manage.py runserver' 2>/dev/null; sleep 0.5; uv run ./manage.py runserver "$@"; }
alias rw="pkill -f rqworker 2>/dev/null; sleep 0.5; python manage.py rqworker high default low"
alias lsh="uv run ./manage.py shell_plus"
alias hsh="heroku run python manage.py shell_plus"
alias rdcd="uv run ./manage.py reset_database --create-demo-agency --su-password testing"
alias rdcd_ui="TC_DATABASE='tutorcruncher2_ui' uv run ./manage.py reset_database --create-demo-agency --su-password testing"
alias showmig="python manage.py showmigrations"

mig() {
    if [ $# -eq 0 ]; then
        echo "Usage: mig <migration_name> [additional_args...]"
        return 1
    fi

    local migration_name="$1"
    shift
    local additional_args="$@"

    # Find migration files matching the name
    local migration_files=($(find . -path "*/migrations/${migration_name}.py" 2>/dev/null))

    if [ ${#migration_files[@]} -eq 0 ]; then
        echo "Error: No migration found with name '${migration_name}'"
        return 1
    elif [ ${#migration_files[@]} -gt 1 ]; then
        echo "Error: Multiple migrations found with name '${migration_name}':"
        for file in "${migration_files[@]}"; do
            echo "  $file"
        done
        echo "Please specify the app manually."
        return 1
    fi

    # Extract app name from the path (get the directory name just before /migrations/)
    local app_name=$(echo "${migration_files[1]}" | sed 's|.*/\([^/]*\)/migrations/.*|\1|')

    echo "Running: python manage.py migrate ${app_name} ${migration_name} ${additional_args}"
    python manage.py migrate "${app_name}" "${migration_name}" ${additional_args}
}


rmmig() {
    if [ $# -eq 0 ]; then
        echo "Usage: removemig <migration_name>"
        return 1
    fi

    local migration_name="$1"

    # Find migration files matching the name
    local migration_files=($(find . -path "*/migrations/${migration_name}.py" 2>/dev/null))

    if [ ${#migration_files[@]} -eq 0 ]; then
        echo "Error: No migration found with name '${migration_name}'"
        return 1
    elif [ ${#migration_files[@]} -gt 1 ]; then
        echo "Error: Multiple migrations found with name '${migration_name}':"
        for file in "${migration_files[@]}"; do
            echo "  $file"
        done
        echo "Please specify the file manually."
        return 1
    fi

    # Extract app name for display
    local app_name=$(echo "${migration_files[1]}" | sed 's|.*/\([^/]*\)/migrations/.*|\1|')

    echo "Removing migration: ${migration_files[1]} (from app: ${app_name})"
    rm "${migration_files[1]}"

    if [ $? -eq 0 ]; then
        echo "Migration removed successfully."
    else
        echo "Error: Failed to remove migration."
    fi
}

makemig() {
    if [ $# -eq 0 ]; then
        echo "Running: python manage.py makemigrations"
        python manage.py makemigrations
    else
        echo "Running: python manage.py makemigrations $@"
        python manage.py makemigrations "$@"
    fi
}


# Git shortcuts
alias gl="git log2"
alias gs="git status"
alias gp="git pull"

# Script shortcuts
alias gb="python3 ~/repos/branch_checkout.py"
alias pt="uv run python ~/repos/run_test.py"
alias lint="python3 ~/repos/run_linter.py"
alias litn="python3 ~/repos/run_linter.py"
alias clean-local-branches="~/repos/clean_branches.sh"

if [[ "$OSTYPE" == darwin* ]]; then
  alias uuu="brew update && brew upgrade"
else
  alias uuu="sudo apt update && sudo apt upgrade"
fi
alias pip="pip3"
alias python="python3"

# TC Variables
export ASYNC_RQ="TRUE"
export DJ_DEBUG="TRUE"
export DJDB="TRUE"

# Custom Aliase
alias cdrepos="cd $HOME/repos"
alias cdtc2="cd $HOME/repos/TutorCruncher2 && src"
alias cdher="cd $HOME/repos/hermes"
alias cdm2="cd $HOME/repos/morpheus && src"

# Redis / Postgres restart — Mac (brew) vs Linux (apt/systemctl)
if [[ "$OSTYPE" == darwin* ]]; then
  alias fixredis="brew services restart redis"
  alias fixsql="brew services restart postgresql"
else
  alias cdi3="cd $HOME/.config/i3/"
  alias calendar="gnome-calendar"
  alias fixredis="sudo apt-get purge redis-server && sudo apt-get install redis-server"
  alias fixsql="sudo systemctl restart postgresql"
fi
