:- encoding(utf8).
% Cristiano Suranyi - 1118428
:- style_check(-discontiguous). % para nao se queixar descontinuidade da BD
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % ver listas completas
:- ["codigoAuxiliar.pl"]. % Ficheiro dado
:- ["bd_estudantes.pl"]. % Ficheiro dado
:- ["listas_palavras.pl"]. % Ficheiro dado
% O teu código deve começar na próxima linha

%-------------------------------------------------------------------------------------------------------------
% 3 Parte 1



%aux-------------------------------
%----------------------------------

% Conta o número de elementos numa lista
% Caso base: lista vazia tem 0 elementos
contagemElementos_de_lista([], 0).
contagemElementos_de_lista([_|T],Contagem):-
    contagemElementos_de_lista(T,Contagem1),
    Contagem is Contagem1 + 1.


% Soma todos os elementos numéricos de uma lista
% Caso base: soma de lista vazia é 0
somaElementos_de_lista([],0).
somaElementos_de_lista([H|T],Soma):-
    somaElementos_de_lista(T,Soma1),
    Soma is Soma1 + H.

%----------------------------------
%----------------------------------



% Calcula a média aritmética dos elementos de uma lista
% Caso especial: lista vazia tem média 0
% Calcula média dividindo soma por contagem e arredonda
media([], 0):-!.
media(Lista,Media):-
    contagemElementos_de_lista(Lista,Contagem),
    somaElementos_de_lista(Lista,Soma),
    Media1 is Soma/Contagem,
    arredonda(Media1,Media).


% Calcula a média das notas de exame dos estudantes com idade entre
% IdadeMin (exclusivo) e IdadeMax (inclusivo)
mediaNotasPorIdade(IdadeMin,IdadeMax,Media):-
    findall(NotaExame,(
        estudante(Id,Idade,_),Idade>IdadeMin,Idade=<IdadeMax,exame(Id,NotaExame)
        ), Lista),
    media(Lista,Media).


% Calcula a média de frequência às aulas dos estudantes de um dado género
freqPorGenero(Genero, MediaFreq):-
    findall(FrequenciaAulas, (
        estudante(Id,_,Genero),atividade(Id,_,_,FrequenciaAulas)
        ), Lista),
    media(Lista,MediaFreq).



%aux-------------------------------
%----------------------------------

% Adiciona um elemento no início de uma lista
adicionaElemento_lista(Elemento,Lista,ListaFinal):-
    ListaFinal = [Elemento|Lista].

% Adiciona elementos no início de uma lista de forma recursiva
adicionaElementos_lista([],Lista,Lista).
adicionaElementos_lista([H|T],Lista,ListaFinal):-
    adicionaElemento_lista(H,Lista,NovaLista),
    adicionaElementos_lista(T,NovaLista,ListaFinal).

% Verifica se uma lista está ordenada
ordenada_lista([]).
ordenada_lista([_]).
ordenada_lista([X,Y|T]):-
    X@=< Y,%eu posso fazer isto pq o nºdos alunos têm o mesmo tamanho e isto n acontece:s100<s2
    ordenada_lista([Y|T]).

% Ordena uma lista através de permutação
ordena(L, L1) :- 
    permutation(L, L1),
    ordenada_lista(L1),
    !.

%----------------------------------
%----------------------------------



% Retorna lista ordenada de IDs de alunos com seguinte indicadores:
% - Alimentação fraca
% - Horas de sono < HorasSono
% - Exercício físico < Exercicio
% - Saúde mental < SaudeMental
alertaSaude(HorasSono, Exercicio, SaudeMental, ListaAlunos):-
    findall(Id, (
        saude(Id,HorasSono1,Alimentacao,ExercicioFisico,SaudeMental1),
        Alimentacao = fraca,
        HorasSono1<HorasSono,ExercicioFisico<Exercicio, 
        SaudeMental1<SaudeMental
        ), ListaNaoOrdenada),
    ordena(ListaNaoOrdenada,ListaAlunos).



%aux-------------------------------
%----------------------------------

% Calcula probabilidade X/Y e arredonda o resultado
% Caso especial: divisão por 0 retorna 0
probabilidade(_,0,0):-!.
probabilidade(X,Y,R):-
    RnArredondado is X/Y,
    arredonda(RnArredondado,R).

% Calcula probabilidade baseada no tamanho de duas listas
probabilidadeDeLista(ListaPossivel,ListaFavoravel,ResultadoProbabilidade):-
    contagemElementos_de_lista(ListaPossivel,ContagemPossivel),
    contagemElementos_de_lista(ListaFavoravel,ContagemFavoravel),
    probabilidade(ContagemPossivel,ContagemFavoravel,ResultadoProbabilidade).

%----------------------------------
%----------------------------------



% Calcula a probabilidade de um aluno ter nota > Nota(definida) e 
% horas em Ecra > HorasEcra(definido) por alunos com horas em Ecra > HorasEcra(definido)
probEcraNotasAltas(HorasEcra, Nota, Probabilidade):-
    findall(Id, (
        exame(Id,NotaExame),
        NotaExame>Nota,
        atividade(Id,_,HorasEcra1,_),
        HorasEcra1>HorasEcra
        ), ListaPossivel),
    findall(Id, (atividade(Id,_,HorasEcra1,_),HorasEcra1>HorasEcra), ListaFavoravel),
    probabilidadeDeLista(ListaPossivel,ListaFavoravel,Probabilidade).

% Subtrai um valor de todos os elementos da lista
subtraiValorDeLista([],_,[]).
subtraiValorDeLista([H|T],Valor,[NovoValor|NovaTail]):-
    NovoValor is H-Valor,
    subtraiValorDeLista(T,Valor,NovaTail).

% Calcula a soma dos quadrados de todos os elementos da lista
somaQuadrados([],0).
somaQuadrados([H|T],Resultado):-
    somaQuadrados(T,Resultado1),
    Resultado is H**2 + Resultado1.

% Calcula o produto escalar de duas listas (vetores)
produtoEscalar([],[],0).
produtoEscalar([H1|T1],[H2|T2],Resultado):-
    produtoEscalar(T1,T2,Resultado1),
    Resultado is H1*H2 + Resultado1.


% Calcula o coeficiente de correlação entre duas listas
correlacao(Lista1, Lista2, Resultado):-
    media(Lista1,MediaLista1),
    subtraiValorDeLista(Lista1,MediaLista1,Desvio1),
    media(Lista2,MediaLista2),
    subtraiValorDeLista(Lista2,MediaLista2,Desvio2),
    produtoEscalar(Desvio1,Desvio2,Numerador),
    somaQuadrados(Desvio1, SomaQuadradosDesvios1),
    somaQuadrados(Desvio2, SomaQuadradosDesvios2),
    Denominador is sqrt(SomaQuadradosDesvios1 * SomaQuadradosDesvios2),
    probabilidade(Numerador,Denominador,Resultado). %probabilidade é uma divisao. 



%-------------------------------------------------------------------------------------------------------------
%Parte 2



% Converte uma palavra (string) numa lista de caracteres
convertePalavraEmLista(Palavra,Lista):-
    string_chars(Palavra, Lista).

% Calcula o número de caracteres de uma palavra
tamanho(Palavra,Tamanho):-
    convertePalavraEmLista(Palavra,Lista),
    contagemElementos_de_lista(Lista,Tamanho).

% Verifica se duas palavras têm o mesmo tamanho e retorna suas listas de caracteres
verificaECalcula(Palavra1, Palavra2, CaracteresPalavra1, CaracteresPalavra2):-
    convertePalavraEmLista(Palavra1,CaracteresPalavra1),
    convertePalavraEmLista(Palavra2,CaracteresPalavra2),
    tamanho(Palavra1,Tamanho1),
    tamanho(Palavra2,Tamanho2),
    Tamanho1=Tamanho2.



%aux-------------------------------
%----------------------------------

% Verifica se um elemento pertence a uma lista
pertence_a_lista(Elemento,[Elemento|_]).
pertence_a_lista(Elemento,[_|T]):-
    pertence_a_lista(Elemento,T).

% Obtém a primeira letra de uma palavra
primeiraLetra(Palavra, Letra):-
    convertePalavraEmLista(Palavra,Lista),
    Lista = [Letra|_].

%----------------------------------
%----------------------------------



% Conta quantas palavras de tamanho N existem na lista do estudante Id
quantasN(Id, N, Quantas):-
    lista_palavras(Id,Lista),
    findall(Palavra, (pertence_a_lista(Palavra,Lista),tamanho(Palavra,N)), Palavras),
    contagemElementos_de_lista(Palavras,Quantas).

% Conta quantas palavras começam com a letra C na lista do estudante Id
quantasC(Id, C, Quantas):-
    lista_palavras(Id,Lista),
    findall(Palavra, (
        pertence_a_lista(Palavra,Lista),
        primeiraLetra(Palavra,C)
        ), Palavras),
    contagemElementos_de_lista(Palavras,Quantas).


% Remove a primeira ocorrência de um elemento da lista
% Caso especial: elemento não existe, retorna lista original
apagaElemento(Z,Lista,Lista):-
    \+pertence_a_lista(Z,Lista),!.

% Caso encontrado: remove e retorna resto
apagaElemento(Elemento, [Elemento|Resto], Resto):-!.

% Caso recursivo: mantém cabeça e continua procurando
apagaElemento(E, [X|Resto], [X|Lista2]) :-
    apagaElemento(E, Resto, Lista2).



%aux-------------------------------
%----------------------------------

% Adiciona posições aos elementos de uma lista, criando tuplos (Elemento, Pos)
adicionaPosicoes([],_,_,[]).
adicionaPosicoes([H|T],NI,NF,ListaF):-
    NI =< NF,
    NI1 is NI +1,
    adicionaPosicoes(T,NI1,NF,Lista),
    Elemento = (H,NI),
    adicionaElemento_lista(Elemento,Lista,ListaF).

%----------------------------------
%----------------------------------



% Retorna lista ordenada de tuplos (Letra, Posição) para cada caractere com 
% a sua posição na palavra
posicoesPalavra(Palavra,Posicoes):-
    convertePalavraEmLista(Palavra,ListaPalavra),
    tamanho(Palavra,Tamanho),
    adicionaPosicoes(ListaPalavra,1,Tamanho,Posicoes_N_Ordenado),
    sort(Posicoes_N_Ordenado,Posicoes).



%aux-------------------------------
%----------------------------------

% Insere um elemento numa posição específica da lista
adicionaElementoNumaPosicao(Elemento,Posicao,Posicao,Lista,[Elemento|Lista]):-!.
adicionaElementoNumaPosicao(Elemento,PosicaoAtual,Posicao,[H|T],[H|ListaFinal]):-
    PosicaoAtual < Posicao,
    PosicaoAtual1 is PosicaoAtual + 1,
    adicionaElementoNumaPosicao(Elemento,PosicaoAtual1,Posicao,T,ListaFinal).

% Remove elemento numa posição específica da lista
apagaPosicao(_,_,[],[]).
apagaPosicao(Posicao,Posicao,[_|T],T):-!.
apagaPosicao(PosicaoAtual,Posicao,[H|T],[H|ListaFinal]):-
    PosicaoAtual < Posicao,
    PosicaoAtual1 is PosicaoAtual + 1,
    apagaPosicao(PosicaoAtual1,Posicao,T,ListaFinal).

% Adiciona elemento e remove o que estava antes nessa posição
adicionaELemento_apagaElementoAntes(Elemento,PosicaoAtual,Posicao,ListaI,ListaF):-
    adicionaElementoNumaPosicao(Elemento,PosicaoAtual,Posicao,ListaI,ListaAindaNFinal),
    Posicao1 is Posicao + 1,
    apagaPosicao(PosicaoAtual,Posicao1,ListaAindaNFinal,ListaF).

% Aplica adicionaELemento_apagaElementoAntes para múltiplas posições
adiciona_apagaElementoAntesComVariasPosicoes(_,[],ListaFinal,ListaFinal).
adiciona_apagaElementoAntesComVariasPosicoes(Elemento,[H|T],ListaInicial,ListaFinal):-
    adicionaELemento_apagaElementoAntes(Elemento,1,H,ListaInicial,ListaAindaNFinal),
    adiciona_apagaElementoAntesComVariasPosicoes(Elemento,T,ListaAindaNFinal,ListaFinal).


% Adiciona o mesmo elemento N vezes no início da lista
adicionaMesmoElementoNumIntervalo(_, PosicaoAtual, Posicao, Lista, Lista):-
    PosicaoAtual > Posicao, !.
adicionaMesmoElementoNumIntervalo(Elemento,PosicaoAtual,Posicao,ListaInicial,ListaF):-
    PosicaoAtual =< Posicao,
    PosicaoAtual1 is PosicaoAtual + 1,
    adicionaElemento_lista(Elemento,ListaInicial,ListaAindaN),
    adicionaMesmoElementoNumIntervalo(Elemento,PosicaoAtual1,Posicao,ListaAindaN,ListaF).
%----------------------------------
%----------------------------------



% Retorna lista com 2 nas posições onde letras coincidem em posição e 
% 0 nas restantes
pista1(PalavraMisterio,Palpite,Pista1):-
    convertePalavraEmLista(PalavraMisterio,ListaPalavraMisterio),
    convertePalavraEmLista(Palpite,ListaPalpite),
    verificaECalcula(PalavraMisterio,Palpite,ListaPalavraMisterio,ListaPalpite),
    tamanho(PalavraMisterio,TamanhoPalavraMisterio),
    adicionaMesmoElementoNumIntervalo(0,1,TamanhoPalavraMisterio,[],ListaCom0),
    posicoesPalavra(PalavraMisterio,PosicoesPalavraMisterio),
    posicoesPalavra(Palpite,PosicoesPalpite),
    findall(Posicao, (
        pertence_a_lista((Letra,Posicao),
        PosicoesPalavraMisterio),
        pertence_a_lista((Letra,Posicao),
        PosicoesPalpite)
        ), Posicoes),
    ordena(Posicoes,PosicoesOrdenadas),
    adiciona_apagaElementoAntesComVariasPosicoes(2,PosicoesOrdenadas,ListaCom0,Pista1).


% Adiciona à pista1 o valor 1 nas posições onde existem letras certas mas
% em posição errada
pista2(PalavraMisterio,Palpite,Pista2):-
    convertePalavraEmLista(PalavraMisterio,ListaPalavraMisterio),
    convertePalavraEmLista(Palpite,ListaPalpite),
    verificaECalcula(PalavraMisterio,Palpite,ListaPalavraMisterio,ListaPalpite),

    pista1(PalavraMisterio,Palpite,Pista1),

    posicoesPalavra(PalavraMisterio,PosicoesPalavraMisterio),
    posicoesPalavra(Palpite,PosicoesPalpite),

    findall(PosicaoCorreta, (
        pertence_a_lista((Letra, PosicaoCorreta), 
        PosicoesPalavraMisterio),
        pertence_a_lista((Letra, PosicaoCorreta), PosicoesPalpite)
        ), PosicoesCorretas),
    findall(Posicao2, (
        pertence_a_lista((Letra,Posicao1),
        PosicoesPalavraMisterio),
        pertence_a_lista((Letra,Posicao2),PosicoesPalpite),
        Posicao1 \= Posicao2,
        \+ pertence_a_lista(Posicao2, PosicoesCorretas)
        ), Posicoes),
    ordena(Posicoes,PosicoesOrdenadas),
    adiciona_apagaElementoAntesComVariasPosicoes(1,PosicoesOrdenadas,Pista1,Pista2).



%aux-------------------------------
%----------------------------------

% Conta quantas vezes uma letra aparece numa lista
contaLetra([],_,0).
contaLetra([H|T],Letra,Quantas):-
    contaLetra(T,Letra,Quantas1),
    (H = Letra -> Quantas is Quantas1 +1;Quantas is Quantas1 +0).

% Retorna lista ordenada de tuplos (Letra, NumOcorrências)
ocorrenciasDeLetrasOrdenado(Lista, Resultado) :-
    ocorrenciasDeLetrasAux(Lista, Lista, Resultado1),
    ordena(Resultado1,Resultado).

ocorrenciasDeLetrasAux(_, [], []).

ocorrenciasDeLetrasAux(Original, [H|T], [(H, Quantas)|Resto]) :-
    \+ pertence_a_lista(H, T),
    !,
    contaLetra(Original, H, Quantas),
    ocorrenciasDeLetrasAux(Original, T, Resto).
% tira as letras repetidas para ficar só com as letras que vamos contar
ocorrenciasDeLetrasAux(Original, [_|T], Resto) :-
    ocorrenciasDeLetrasAux(Original, T, Resto).


% Identifica posições (tuplos) que devem ser removidas (letras em excesso)
% Primeira Lista são os tuplos com as letras e as suas respetivas posições
% Segunda Lista são os tuplos com as letras e o nº de ocorrencia em excesso
posicoesQueDevoApagar(_, [], _, ListaF, ListaF):-!.
posicoesQueDevoApagar(_, _, [], ListaF, ListaF):-!.

% Adiciona na ListaFinal as letras com as suas posições caso as Letras das 
% duas listas sejam igual e que ainda estejam em excesso, caso contrario avança
posicoesQueDevoApagar(I,[(Letra1,Posicao)|T],[(Letra2,N_Excesso)|T1],ListaAcc,ListaF):-
    I < N_Excesso,
    Letra1 = Letra2,!,
    I1 is I + 1,
    adicionaElemento_lista(Posicao,ListaAcc,ListaAcc1),
    posicoesQueDevoApagar(I1,T,[(Letra2,N_Excesso)|T1],ListaAcc1,ListaF).

posicoesQueDevoApagar(I,[(Letra1,_)|T],[(Letra2,N_Excesso)|T1],ListaAcc,ListaF):-
    Letra1 \= Letra2,!,
    posicoesQueDevoApagar(I,T,[(Letra2,N_Excesso)|T1],ListaAcc,ListaF).

posicoesQueDevoApagar(I,[(Letra1,_)|T],[(_,N_Excesso)|T1],ListaAcc,ListaF):-
    I >= N_Excesso,!,
    posicoesQueDevoApagar(0,[(Letra1,_)|T],T1,ListaAcc,ListaF).% reset I, avança T1

%----------------------------------
%----------------------------------



% Remove da pista2 os ultimos 1s correspondentes a letras em excesso (quando o
% palpite tem mais ocorrências de uma letra do que a palavra mistério)
pista3(PalavraMisterio,Palpite,Pista3):-
    convertePalavraEmLista(PalavraMisterio,ListaPalavraMisterio),
    convertePalavraEmLista(Palpite,ListaPalpite),
    verificaECalcula(PalavraMisterio,Palpite,ListaPalavraMisterio,ListaPalpite),

    pista2(PalavraMisterio,Palpite,Pista2),

    posicoesPalavra(PalavraMisterio,PosicoesPalavraMisterio),
    posicoesPalavra(Palpite,PosicoesPalpite),

    findall(PosicaoCorreta, (
        pertence_a_lista((Letra, PosicaoCorreta),
        PosicoesPalavraMisterio),
        pertence_a_lista((Letra, PosicaoCorreta), PosicoesPalpite)
        ),PosicoesCorretas),
    findall((Letra,Posicao2), (
        pertence_a_lista((Letra,Posicao1),PosicoesPalavraMisterio),
        pertence_a_lista((Letra,Posicao2),PosicoesPalpite),
        Posicao1 \= Posicao2,
        \+ pertence_a_lista(Posicao2, PosicoesCorretas)
        ), LetrasEmPosicoesErradas),
    
    ocorrenciasDeLetrasOrdenado(ListaPalavraMisterio,OcorrenciasPalavraMisterio),
    ocorrenciasDeLetrasOrdenado(ListaPalpite,OcorrenciasPalpite),

    findall((Letra,X),(
        pertence_a_lista((Letra,Quantas1),OcorrenciasPalavraMisterio),
        pertence_a_lista((Letra,Quantas2),OcorrenciasPalpite),
        Quantas1<Quantas2,
        X is Quantas2 - Quantas1
        ),LetrasCom_n_OcorrenciasEmExcesso),

    ordena(LetrasEmPosicoesErradas,LetrasEmPosicoesErradasOrdenado),
    reverse(LetrasEmPosicoesErradasOrdenado, R_LetrasEmPosicoesErradas),
    reverse(LetrasCom_n_OcorrenciasEmExcesso, R_LetrasCom_n_OcorrenciasEmExcesso),
    
    posicoesQueDevoApagar(0,
        R_LetrasEmPosicoesErradas,
        R_LetrasCom_n_OcorrenciasEmExcesso,
        [],
        PosicoesAPagar),
    adiciona_apagaElementoAntesComVariasPosicoes(0,PosicoesAPagar,Pista2,Pista3).





%-------------------------------------------------------------------------------------------------------------
%Parte 3

% Verifica se filme de terror está nas posições 3, 4 ou 7
terror(Filme,Lista):-
    contagemElementos_de_lista(Lista,TamanhoLista),
    adicionaPosicoes(Lista,1,TamanhoLista,ListaComPosicoes),
    pertence_a_lista((Filme,Posicao),ListaComPosicoes),
    (Posicao = 3 ; Posicao = 4; Posicao = 7),!.

% Verifica se filme está exatamente na sessão especificada
soPode(Filme, Sessao,Lista):-
    contagemElementos_de_lista(Lista,TamanhoLista),
    adicionaPosicoes(Lista,1,TamanhoLista,ListaComPosicoes),
    pertence_a_lista((Filme,Posicao),ListaComPosicoes),
    Sessao = Posicao,!.

% Verifica se filme nunca está na sessão especificada
nunca(Filme,Sessao,Lista):-
    \+ soPode(Filme, Sessao,Lista).

% Verifica se Filme2 vem imediatamente após Filme1
% Não pode haver consecutividade após posições 4 e 7 
seguido(Filme1, Filme2,Lista):-
    contagemElementos_de_lista(Lista,TamanhoLista),
    adicionaPosicoes(Lista,1,TamanhoLista,ListaComPosicoes),
    pertence_a_lista((Filme1,Posicao1),ListaComPosicoes),
    pertence_a_lista((Filme2,Posicao2),ListaComPosicoes),
    Posicao1 \= 4,
    Posicao1 \= 7,
    PosicaoConsecutiva1 is Posicao1 +1,
    PosicaoConsecutiva1 = Posicao2.

% Verifica se dois filmes não são consecutivos (em nenhuma ordem)
naoSeguido(Filme1, Filme2,Lista):-
    \+ seguido(Filme1, Filme2,Lista),
    \+ seguido(Filme2, Filme1,Lista).

% Verifica se Filme1 aparece antes de Filme2 na programação
antes(Filme1, Filme2,Lista):-
    contagemElementos_de_lista(Lista,TamanhoLista),
    adicionaPosicoes(Lista,1,TamanhoLista,ListaComPosicoes),
    pertence_a_lista((Filme1,Posicao1),ListaComPosicoes),
    pertence_a_lista((Filme2,Posicao2),ListaComPosicoes),
    Posicao1 < Posicao2,!.



%aux-------------------------------
%----------------------------------

% Verifica se uma programação satisfaz todas as restrições
% Caso base: lista vazia de restrições sempre é satisfeita
verificaRestricoes(_, []).%se isto acontecer dá True
verificaRestricoes(ListaFilmes, [Restricao|Resto]) :-
    call(Restricao, ListaFilmes),  % adiciona listaFilmes como ultimo argumento a funçao q estiver na listaRestriçoes
    verificaRestricoes(ListaFilmes, Resto).
%----------------------------------
%----------------------------------



% Gera todas as programações válidas de 7 sessões que satisfazem as restrições
% - Se menos de 7 filmes, preenche com 'empty'
% - Retorna lista de todas as permutações válidas
% - Se não houver soluções, retorna lista vazia []
maratonaFilmes(ListaFilmes, ListaRestricoes, Programacao):-
    contagemElementos_de_lista(ListaFilmes,N_ListaFilmes),
    (N_ListaFilmes < 8 
        -> EmFalta is 7 - N_ListaFilmes,
        adicionaMesmoElementoNumIntervalo(empty,1,EmFalta,ListaFilmes,ListaFilmesComEmpty1),
        ListaFilmesComEmpty = ListaFilmesComEmpty1
        ;ListaFilmesComEmpty = ListaFilmes),
    findall(P, (permutation(ListaFilmesComEmpty, P), verificaRestricoes(P, ListaRestricoes)), Programacao).























