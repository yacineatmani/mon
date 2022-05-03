
#!/bin/bash

#shopt -s extglob

file_path="/home/yacine/mon/robot.sh" #CHANGETHIS

if [ ! -f ~/.local/bin/bert ]; then
    case :$PATH: in
    *:$HOME/.local/bin:*)
        echo "You can put me in your path to make it easier to ask me things.."
        sleep 0.5
        echo -n "if you run:\nln -s $PWD/bert.sh ~/.local/bin/bert\n you will be able to ask me questions from anywhere! (on your computer)"
        echo -e "If you want to get rid of me after doing this.. :(\nthen you can run:  unlink (which bert) "
        ;;
    *)
        echo "$HOME/.local/bin not in $PATH, maybe add it to you path or put me somewhere else.." >&2
        ;;
    esac
fi

calculator() {
    source $/home/yacine/mon/robotjob.sh/calculate.sh
}

timeDate() {
    source $/home/yacine/mon/robotjob.sh/time.sh
}

jokes() {
    source /home/yacine/mon/robotjob.sh
}

weather() {
    source $/home/yacine/mon/robotjob.sh/weather.sh
}

introPostSpeak() {
    local yesText="Thank you! Ah that's better"
    local noText="Oh ok... well that's ok."
    local introText="Shall I tell you what I can do? Type help if you want me to. Or if you already know go ahead and type it now..."
    if [ "$speak" == "yes" ]; then
        echo "$yesText"
        espeak-ng "$yesText"
        sleep 1
        echo -e "$introText"
        espeak-ng "$introText"

    else
        echo -e "$noText"
        sleep 1
        echo -e "$introText"
    fi
}

intro() {
    if [ -z $1 ]; then
        echo "Hello, my name is Bert."
        echo "...."
        sleep 1
        echo "I am a bot 🤖"
        sleep 1
        echo "You can ask me lots of things."
        sleep 1
        echo "But first, I can speak to you if you want..."
        sleep 0.5
        echo "Will you let me speak?"
        read speak
        cheakForEspeak
        echo "ok.."
        sleep 0.2
        introPostSpeak
        read -a choice
        function=${choice[0]}
        argument1=${choice[1]}
        argument2=${choice[2]}
        argument3=${choice[3]}
    else
        if [ "$1" == "speak" ]; then
            speak="yes"
            function=$2
            argument1=$3
            argument2=$4
            argument3=$5
        else
            function=$1
            argument1=$2
            argument2=$3
            argument3=$4
        fi
    fi
}

cheakForEspeak() {
    if [ "$speak" == "yes" ] && ! command -v espeak-ng &>/dev/null; then
        echo -e "You need to install espeak if you want me to speak..\n have a read here: https://https://github.com/espeak-ng/espeak-ng"
        exit 1
    fi
}

mainLogic() {
    if [ -z $function ]; then
        echo "Don't be shy! Ask away."
    else
        case $function in
        help)
            helpText="I am happy to help! I can tell you date and time. Type time for this. I can tell you a joke. Type joke for this. I can also calculate some basic maths for you. Type calculate followed by two numbers seperated by an arithmetic operator. You can type your choice now..."
            case $speak in
            yes)
                echo $helpText
                echo $helpText | espeak-ng
                ;;
            no)
                echo $helpText
                ;;
            esac
            read -a choice
            function=${choice[0]}
            argument1=${choice[1]}
            argument2=${choice[2]}
            argument3=${choice[3]}
            mainLogic $function $argument1 $argument2 $argument3
            ;;
        weather | Weather)
            echo $argument1
            if [ -z $argument1 ]; then
                case $speak in
                yes)
                    echo "Here is the Weather where you are"
                    espeak-ng "Here is the Weather where you are"
                    echo $(weather)
                    echo $(weather) | sed "s/+//" | espeak-ng
                    ;;
                *)
                    weather
                    ;;
                esac
            else
                echo -e "Here is the Weather in $argument1"
                if [ "$speak" == "yes" ]; then
                    espeak-ng "Here is the Weather in $argument1"
                    weather $argument1
                    echo $(weather $argument1) | sed "s/+//" | espeak-ng
                else
                    weather $argument1
                fi
            fi
            ;;
        Joke | joke)
            if [ "$speak" == "yes" ]; then
                echo "Harvesting a fresh joke from the web....."
                espeak-ng "Harvesting a fresh joke from the web....."
                echo -e "\n"
                returnedJoke=$(jokes)
                echo $returnedJoke
                echo $returnedJoke | sed "s/+//" | espeak-ng
            else
                echo "Harvesting a fresh joke from the web....."
                echo -e "\n"
                jokes
            fi
            ;;
        time | Time)
            if [ "$speak" == "yes" ]; then
                timeDate
                echo $(timeDate) | sed "s/+//" | espeak-ng
            else
                timeDate
            fi
            ;;
        calculate | Calculate)
            #echo "case worked"
            if [ -z $argument2 ]; then
                #echo "failed if"
                response="You have to give two numbers and an operator, like 2 + 3"
                case $speak in
                yes)
                    echo $response
                    echo $response | espeak-ng
                    ;;
                *)
                    echo $response
                    ;;
                esac
            else
                calculation=$(calculator $argument1 $argument2 $argument3)
                #echo "else worked"
                case $speak in
                yes)
                    echo "$argument1 $argument2 $argument3 is $calculation"
                    echo "$argument1 $argument2 $argument3 is $calculation" | espeak
                    ;;
                *)
                    echo "$argument1 $argument2 $argument3 is $calculation"
                    ;;
                esac
            fi
            ;;
        *)
            echo "dunno sorry"
            ;;
        esac
    fi
}

main() {
    #Interactive Mode
    intro $1 $2 $3 $4 $5
    #echo from main $function $arguments
    mainLogic $function $argument1 $argument2 $argument3
}

main $1 $2 $3 $4 $5
