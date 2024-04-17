function printtable(table)
    if type(table) ~= "table" then
        print("isso n e uma tabela :D")
        return
    end
    print("------------------")
    for i, v in pairs(table) do
        print(tostring(i) .. " = " .. tostring(v))
    end
    print("------------------")
end

function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result;
end

function booltoint(bool)
    return bool and 1 or 0
end

local chars = {"a","b","c","d","e","f","g","h"}
local chars2 = {["a"] = 1, ["b"] = 2, ["c"] = 3, ["d"] = 4, ["e"] = 5, ["f"] = 6, ["g"] = 7, ["h"] = 8}

local game = {
    tabuleiro = {},
    qmjoga = "Brancos",
    startpos = "ra1hb1bc1qd1ke1bf1hg1rh1pa2pb2pc2pd2pe2pf2pg2ph2 ra8hb8bc8qd8ke8bf8hg8rh8pa7pb7pc7pd7pe7pf7pg7ph7 00",
    reijamoveu = {branco = false, preto = false},
    allmoves = {}
}

function printtabuleiro()
    if game.tabuleiro["a"] == nil then return end
    for j = 8, 1, -1 do
        local linha = ""
        for i = 1, 8 do
            linha = linha .. game.tabuleiro[chars[i]][j].char .. " "
        end
        print(linha)
    end
    print("\n")
end

function reset_tabuleiro()
    local tabuleiro = {}
    for j = 1, 8 do
        tabuleiro[chars[j]] = {}
        for i = 1, 8 do
            tabuleiro[chars[j]][i] = {char = " ", cor = "", moves = {}}
        end
    end
    game.tabuleiro = tabuleiro
    game.reijamoveu = {branco = false, preto = false}
    game.allmoves = {}
    game.qmjoga = "Brancos"
end

function charat(string, lugar)
    return string:sub(lugar,lugar)
end

function setpos(pos)
    reset_tabuleiro()
    local lados = Split(pos, " ")

    local brancas = lados[1]
    for i = 1, #brancas/3 do
        local reali = i*3-2
        game.tabuleiro[charat(brancas, reali+1)][tonumber(charat(brancas, reali+2))] = {char = charat(brancas, reali), cor = "B"}
    end

    local pretas = lados[2]
    for i = 1, #pretas/3 do
        local reali = i*3-2
        game.tabuleiro[charat(pretas, reali+1)][tonumber(charat(pretas, reali+2))] = {char = charat(pretas, reali), cor ="P"}
    end

    local reijamoveu = lados[3]
    game.reijamoveu = {branco = charat(reijamoveu, 1) == "1", preto = charat(reijamoveu, 2) == "1"}

    updatemoves()
end

function getpos()
    local lados = {branco = "", preto = ""}
    for i, v in pairs(game.tabuleiro) do
        for j, k in pairs(v) do
            if k.cor ~= "" then
                if k.cor == "B" then
                    lados.branco = lados.branco .. k.char .. i .. j
                else
                    lados.preto = lados.preto .. k.char .. i .. j
                end
            end
        end
    end
    return lados.branco .. " " .. lados.preto .. " " .. booltoint(game.reijamoveu.branco) .. booltoint(game.reijamoveu.preto)
end

function somachar(char, soma)
    local atual = chars2[char]
    return chars[atual+soma]
end

function getretas(letra, numero, cor, casas, socima, sobaixo)
    local casas = casas or 7
    local moves = {}
    local tabuleiro = game.tabuleiro
    
    if sobaixo then goto baixo end

    for crescente = 1, casas do --cima
        local verificado = tabuleiro[letra][numero+crescente]
        if verificado == nil or verificado.cor == cor then
            break
        else
            table.insert(moves, {letra=letra,numero=numero+crescente})
            if verificado.cor ~= "" then
                break
            end
        end
    end

    if socima then return moves end

    ::baixo::

    for crescente = 1, casas do --baixo
        local verificado = tabuleiro[letra][numero-crescente]
        if verificado == nil or verificado.cor == cor then
            break
        else
            table.insert(moves, {letra=letra,numero=numero-crescente})
            if verificado.cor ~= "" then
                break
            end
        end
    end

    if sobaixo then return moves end
    
    for crescente = 1, casas do --direita
        local verificado = tabuleiro[somachar(letra, crescente)]
        if verificado == nil or verificado[numero].cor == cor then
            break
        else
            table.insert(moves, {letra=somachar(letra, crescente),numero=numero})
            if verificado[numero].cor ~= "" then
                break
            end
        end
    end

    for crescente = 1, casas do --esquerda
        local verificado = tabuleiro[somachar(letra, -crescente)]
        if verificado == nil or verificado[numero].cor == cor then
            break
        else
            table.insert(moves, {letra=somachar(letra, -crescente),numero=numero})
            if verificado[numero].cor ~= "" then
                break
            end
        end
    end

    return moves
end

function getdiagonais(letra, numero, cor, casas)
    local casas = casas or 7
    local moves = {}
    local tabuleiro = game.tabuleiro

    for crescente = 1, casas do --direita cima
        local verificado = tabuleiro[somachar(letra, crescente)]
        if verificado == nil or verificado[numero+crescente] == nil or verificado[numero+crescente].cor == cor then
            break
        else
            table.insert(moves, {letra=somachar(letra, crescente),numero=numero+crescente})
            if verificado[numero+crescente].cor ~= "" then
                break
            end
        end
    end

    for crescente = 1, casas do --direita baixo
        local verificado = tabuleiro[somachar(letra, crescente)]
        if verificado == nil or verificado[numero-crescente] == nil or verificado[numero-crescente].cor == cor then
            break
        else
            table.insert(moves, {letra=somachar(letra, crescente),numero=numero-crescente})
            if verificado[numero-crescente].cor ~= "" then
                break
            end
        end
    end

    for crescente = 1, casas do --esquerda cima
        local verificado = tabuleiro[somachar(letra, -crescente)]
        if verificado == nil or verificado[numero+crescente] == nil or verificado[numero+crescente].cor == cor then
            break
        else
            table.insert(moves, {letra=somachar(letra, -crescente),numero=numero+crescente})
            if verificado[numero+crescente].cor ~= "" then
                break
            end
        end
    end

    for crescente = 1, casas do --esquerda baixo
        local verificado = tabuleiro[somachar(letra, -crescente)]
        if verificado == nil or verificado[numero-crescente] == nil or verificado[numero-crescente].cor == cor then
            break
        else
            table.insert(moves, {letra=somachar(letra, -crescente),numero=numero-crescente})
            if verificado[numero-crescente].cor ~= "" then
                break
            end
        end
    end

    return moves
end

function getvolta(letra, numero, cor, casas)
    local casas = casas or 7
    local moves = {}
    for i, v in pairs(getretas(letra, numero, cor, casas)) do
        table.insert(moves, v)
    end
    for i, v in pairs(getdiagonais(letra, numero, cor, casas)) do
        table.insert(moves, v)
    end
    return moves
end

function getls(letra, numero, cor)
    local moves = {}
    local tabuleiro = game.tabuleiro

    local loc = game.tabuleiro[letra][numero]

    local direita = game.tabuleiro[somachar(letra, 2)]
    if direita then
        if direita[numero+1] and direita[numero+1].cor ~= cor then table.insert(moves, {letra = somachar(letra, 2), numero = numero+1}) end
        if direita[numero-1] and direita[numero-1].cor ~= cor then table.insert(moves, {letra = somachar(letra, 2), numero = numero-1}) end
    end

    local esquerda = game.tabuleiro[somachar(letra, -2)]
    if esquerda then
        if esquerda[numero+1] and esquerda[numero+1].cor ~= cor then table.insert(moves, {letra = somachar(letra, -2), numero = numero+1}) end
        if esquerda[numero-1] and esquerda[numero-1].cor ~= cor then table.insert(moves, {letra = somachar(letra, -2), numero = numero-1}) end
    end

    local baixo = game.tabuleiro[letra][numero-2]
    if baixo then
        if game.tabuleiro[somachar(letra, 1)] and game.tabuleiro[somachar(letra, 1)][numero-2].cor ~= cor then table.insert(moves, {letra = somachar(letra, 1), numero = numero-2}) end
        if game.tabuleiro[somachar(letra, -1)] and game.tabuleiro[somachar(letra, -1)][numero-2].cor ~= cor then table.insert(moves, {letra = somachar(letra, -1), numero = numero-2}) end
    end

    local cima = game.tabuleiro[letra][numero+2]
    if cima then
        if game.tabuleiro[somachar(letra, 1)] and game.tabuleiro[somachar(letra, 1)][numero+2].cor ~= cor then table.insert(moves, {letra = somachar(letra, 1), numero = numero+2}) end
        if game.tabuleiro[somachar(letra, -1)] and game.tabuleiro[somachar(letra, -1)][numero+2].cor ~= cor then table.insert(moves, {letra = somachar(letra, -1), numero = numero+2}) end
    end

    return moves
end

function getmoves(letra, numero, cor, char)
    local moves = {}
    if char == "h" then
        return getls(letra, numero, cor)
    elseif char == "r" then
        return getretas(letra, numero, cor)
    elseif char == "b" then
        return getdiagonais(letra, numero, cor)
    elseif char == "q" then
        return getvolta(letra, numero, cor)
    elseif char == "k" then
        return getvolta(letra, numero, cor, 1)
    elseif char == "p" then
        if cor == "B" then
            return getretas(letra, numero, cor, 1, true)
        else
            return getretas(letra, numero, cor, 1, false, true)
        end
    else
        return {}
    end
end

function updatemoves()
    game.allmoves = {}
    for i, v in pairs(game.tabuleiro) do
        for j, k in pairs(v) do
            game.tabuleiro[i][j].moves = {}
            local moves = getmoves(i,j,k.cor,k.char)
            for l, p in pairs(moves) do
                local input_command_string = k.char .. i .. j .. " to " .. p.letra .. p.numero
                game.tabuleiro[i][j].moves[p.letra .. p.numero] = 1
                game.allmoves[input_command_string] = 1
            end
        end
    end
end

function execmove(movestring)
    if not game.allmoves[movestring] then print("Movimento invalido") return end

    local comando = Split(movestring, " ")

    game.tabuleiro[charat(comando[3], 1)][tonumber(charat(comando[3], 2))] = game.tabuleiro[charat(comando[1], 2)][tonumber(charat(comando[1], 3))]

    game.tabuleiro[charat(comando[1], 2)][tonumber(charat(comando[1], 3))] = {char = " ", cor = "", moves = {}}

    updatemoves()
end


setpos(game.startpos)
printtabuleiro()
execmove("hb1 to c3")
printtabuleiro()
execmove("hc3 to a4")
printtabuleiro()

