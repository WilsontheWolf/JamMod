local jd_def = JokerDisplay.Definitions

jd_def["j_jam_double_vision"] = {}
jd_def["j_jam_prosopagnosia"] = {}
jd_def["j_jam_pessimist"] = {}
jd_def["j_jam_one_more_time"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips" }
    },
    reminder_text = {
        { text = "(when sold)" },
    },
    text_config = { colour = G.C.WHITE },
    calc_function = function(card)
        if G.STATE == G.STATES.HAND_PLAYED and card.joker_display_values.chips then return end -- Don't show the score before scoring is over
        card.joker_display_values.chips = G.GAME.round_resets.jam_last_chips or 0
    end
}
jd_def["j_jam_tarlton"] = {}
jd_def["j_jam_greedy_pot"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability", ref_value = "extra" },
    },
    reminder_text = {
        { text = "cards" },
    },
    text_config = { colour = G.C.IMPORTANT },
}
jd_def["j_jam_all_ones"] = {}
jd_def["j_jam_brownie"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "retriggers" },
        { text = ")" },
    },
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand then return 0 end
        return (playing_card:get_id() == 2) and
            joker_card.ability.extra.retriggers * JokerDisplay.calculate_joker_triggers(joker_card) or 0
    end
}
jd_def["j_jam_buckleswasher"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "exp" }
            }
        }
    },
}
jd_def["j_jam_scouter"] = {}
jd_def["j_jam_pierrot"] = {}
jd_def["j_jam_deposit"] = {
        reminder_text = {
            { text = "(no rank or suit)" },
        },
        retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
            if held_in_hand then return 0 end
            return (playing_card:get_id() <= -100) and
                1 * JokerDisplay.calculate_joker_triggers(joker_card) or 0
        end
}
jd_def["j_jam_safari"] = {}
