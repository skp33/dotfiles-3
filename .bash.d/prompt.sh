#
# Green working directory on it's own line.
#
# Sans git fanciness: PS1="\n\[\033[0;32m\]\w\[\033[0m\]\n[\u@\h]\$ "
#      without color: PS1="\n\w\n[\u@\h]\$ "
#
        RED="\[\033[01;31m\]"
     YELLOW="\[\033[01;33m\]"
      GREEN="\[\033[01;32m\]"
       BLUE="\[\033[01;34m\]"
  LIGHT_RED="\[\033[0;31m\]"
LIGHT_GREEN="\[\033[0;32m\]"
      WHITE="\[\033[1;37m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
 COLOR_NONE="\[\033[0m\]"

function git_prompt_info {
    local git_status="$(git status 2> /dev/null)"
    if [[ -z ${git_status} ]]; then exit; fi

    local state stash remote branch

    local git_stash="$(git stash list 2> /dev/null)"
    local branch_pattern="^On branch ([^${IFS}]*)"
    local remote_pattern="Your branch is (.*) of"
    local diverge_pattern="Your branch and (.*) have diverged"

    if [[ ! ${git_status} =~ "working directory clean" ]]; then
        state="${RED}⚡"
    fi
    if [[ -n ${git_stash} ]]; then
        stash="${RED}☰"
    fi
    # add an else if or two here if you want to get more specific
    if [[ ${git_status} =~ ${remote_pattern} ]]; then
        if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
            remote="${YELLOW}↑"
        else
            remote="${YELLOW}↓"
        fi
    fi
    if [[ ${git_status} =~ ${diverge_pattern} ]]; then
        remote="${YELLOW}↕"
    fi
    if [[ ${git_status} =~ ${branch_pattern} ]]; then
        branch=${BASH_REMATCH[1]}
        echo " ${GREEN}(${WHITE}± ${branch} ${stash}${state}${remote}${GREEN})${COLOR_NONE}"
    fi
}

# TODO: for speed, make only one `hg prompt` call and massage data
function hg_prompt_info {
    # Because my home dir is an hg repo for dotfiles...
    local hg_root="$(hg root 2> /dev/null)"
    if [ -z ${hg_root} ] || [[ ${hg_root} = $HOME ]]; then exit; fi

    local state shelf

    # Override the hg-prompt extensions status characters
    local hg_status="$(hg prompt '{status}')"
    if [[ -n $hg_status ]]; then
        state="${RED}⚡"
    fi

    # TODO: the hamburger would also be appropriate for mq patches
    local hg_shelf="$(hg shelve --list 2> /dev/null)"
    if [[ -n $hg_shelf ]]; then
        shelf="${RED}☰"
    fi

    # Imperfect, but I almost always want to have a 'master' bookmark
    local hg_prompt="$(hg prompt '{{branch|quiet}:}{{bookmark}}{:{patch}}')"
    echo " ${GREEN}(${WHITE}☿ ${hg_prompt} ${shelf}${state}${GREEN})${COLOR_NONE}"
}


# chruby 0.4.0 is said to add $RUBY_PATCHLEVEL
# https://twitter.com/postmodern_mod3/status/288985963559022592
#
# RVM is supposed to support the same variables now, but I haven't tested yet.
function ruby_version {
    # chruby will helpfully unset RUBY_VERSION if system version is used; RVM?
    if [[ -z "$RUBY_VERSION" ]]; then exit; fi

    local ruby=" ${RED}♦ "

    # Only show interpreter if it's interesting, i.e. not MRI
    if [[ "$RUBY_ENGINE" != "ruby" ]]; then
        ruby+="${RUBY_ENGINE}-"
    fi

    ruby+="${RUBY_VERSION}${RUBY_PATCHLEVEL:+-}${RUBY_PATCHLEVEL:-}"
    echo "${ruby}${COLOR_NONE}"
}

function python_version {
    if [[ -z "$PYENV_VERSION" ]] || [[ "$PYENV_VERSION" == "system" ]]; then exit; fi

    echo " ${LIGHT_GREEN}🐍  ${PYENV_VERSION}${COLOR_NONE}"
}

# Simply reminds us we're in a sandbox. Could do more shell tricks, for some
# inspiration see:
#
#   - http://www.edsko.net/2013/02/10/comprehensive-haskell-sandboxes/
#   - zsh project: https://github.com/calvinchengx/cabalenv
function cabal_prompt_info {
    if [ ! -r *.cabal ]; then exit; fi

    declare state

    if [ -f cabal.sandbox.config ]; then
        state="sandboxed"
    else
        state="not sandboxed"
    fi

    echo " ${GREEN}(${WHITE}λ ${state}${GREEN})${COLOR_NONE}"
}

function prompt_func {
    local previous_exit_code=$?

    local prompt="${GREEN}\w${COLOR_NONE}"
    prompt+="$(git_prompt_info)"
    prompt+="$(hg_prompt_info)"
    prompt+="$(cabal_prompt_info)"
    prompt+="$(ruby_version)"
    prompt+="$(python_version)"
    prompt+="\n[\u@\h]"

    # Dirty the $ on end of prompt if last exit code was a failure
    if [ "$previous_exit_code" -eq 0 ]; then
        prompt+="\$"
    else
        prompt+="${RED}\$${COLOR_NONE}"
    fi

    PS1="\n${prompt} "
}

# Would be best to call original first, but that breaks last exit status sniffing. Hmm.
# TODO: anything PIPESTATUS-like for this situation?
export PROMPT_COMMAND="prompt_func; $PROMPT_COMMAND"

