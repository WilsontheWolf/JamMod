local jd_def = JokerDisplay.Definitions

jd_def["j_jam_double_vision"] = {}
jd_def["j_jam_prosopagnosia"] = {}
jd_def["j_jam_pessimist"] = {}
jd_def["j_jam_one_more_time"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips" }
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        card.joker_display_values.chips = G.GAME.round_resets.jam_last_chips or 0
    end
}
