# Prolog Wordle And LogicSolvers IST-LP-Project

[![Language](https://img.shields.io/badge/language-Prolog-blue.svg)](https://www.swi-prolog.org/)
[![SWI-Prolog](https://img.shields.io/badge/SWI--Prolog-9.x-orange.svg)](https://www.swi-prolog.org/download/stable)
[![Course](https://img.shields.io/badge/course-Logic%20for%20Programming-green.svg)](https://fenix.tecnico.ulisboa.pt/disciplinas/LP2112/2025-2026/1-semestre)
[![University](https://img.shields.io/badge/IST-Universidade%20de%20Lisboa-lightgrey.svg)](https://tecnico.ulisboa.pt/en/)

A logic programming project written in **SWI-Prolog**, developed for the **Logic for Programming (Lógica para Programação, LP)** course at [Instituto Superior Técnico](https://tecnico.ulisboa.pt/en/) (University of Lisbon), 1st semester of 2025/2026.

The project is split into three independent parts, each showing a different side of Prolog:

1. **Statistical analysis** over a fact database of 600 students (means, conditional probabilities, Pearson correlation, health alerts).
2. **A Wordle-style word game** with three levels of feedback (`pista1`, `pista2`, `pista3`), including correct handling of repeated letters.
3. **A movie marathon scheduler** that solves a constraint satisfaction problem by generate-and-test.

---

## Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Part 1 – Student Data Analysis](#part-1--student-data-analysis)
- [Part 2 – Word Game (Wordle)](#part-2--word-game-wordle)
- [Part 3 – Movie Marathon Scheduler](#part-3--movie-marathon-scheduler)
- [Running the Tests](#running-the-tests)
- [Design Notes](#design-notes)
- [Author](#author)
- [Acknowledgements & Academic Note](#acknowledgements--academic-note)

---

## Features

- Pure Prolog implementations of list utilities (length, sum, membership, insertion, removal, ordering) written from scratch with explicit recursion, without relying on library shortcuts such as `sum_list/2` or `length/2` in the solution code.
- Statistical predicates: arithmetic mean, filtered means, conditional probability, and correlation coefficient, all rounded to two decimal places.
- Wordle-like feedback engine with three progressive difficulty levels.
- Playable command-line game with coloured terminal output.
- Declarative scheduling with composable constraints, using higher-order `call/N`.
- A public test suite using `plunit`.

---

## Project Structure

```
.
├── projetoLP.pl          # Main solution (all three parts)
├── jogar.pl              # Interactive Wordle game (provided by the course)
├── codigoAuxiliar.pl     # Rounding helper (provided by the course)
├── bd_estudantes.pl      # Student fact database (provided by the course)
├── listas_palavras.pl    # Word lists: `mini` and `pt` (provided by the course)
├── testes_publicos.plt   # Public plunit test suite (provided by the course)
└── README.md
```

`projetoLP.pl` loads `codigoAuxiliar.pl`, `bd_estudantes.pl` and `listas_palavras.pl` automatically, so all files must live in the same directory.

---

## Getting Started

### Prerequisites

- [SWI-Prolog](https://www.swi-prolog.org/download/stable) 9.x or newer (UTF-8 support is required, since the word lists contain accented characters).

### Run

```bash
swipl projetoLP.pl
```

You will land in the interactive Prolog toplevel with the whole project loaded.

---

## Part 1 – Student Data Analysis

The database `bd_estudantes.pl` stores one block of facts per student:

| Predicate | Arguments |
|---|---|
| `estudante/3` | `Id, Age, Gender` |
| `atividade/4` | `Id, StudyHours, ScreenHours, ClassAttendance(%)` |
| `saude/5` | `Id, SleepHours, Diet (fraca/razoavel/boa), PhysicalExercise, MentalHealth` |
| `exame/2` | `Id, ExamScore` |

### Predicates

| Predicate | Description |
|---|---|
| `media/2` | Arithmetic mean of a list (returns `0` for an empty list). |
| `mediaNotasPorIdade/3` | Mean exam score of students whose age is in `(IdadeMin, IdadeMax]`. |
| `freqPorGenero/2` | Mean class attendance for a given gender. |
| `alertaSaude/4` | Sorted list of students with poor diet, sleep, exercise and mental health below the given thresholds. |
| `probEcraNotasAltas/3` | Probability of a high exam score among students with high screen time. |
| `subtraiValorDeLista/3` | Subtracts a value from every element of a list. |
| `somaQuadrados/2` | Sum of the squares of a list. |
| `produtoEscalar/3` | Dot product of two vectors. |
| `correlacao/3` | Pearson correlation coefficient between two lists. |

### Examples

```prolog
?- media([1, 2, 4, 6], M).
M = 3.25.

?- mediaNotasPorIdade(16, 18, M).
M = 69.87.

?- alertaSaude(6, 3, 5, Alunos).
Alunos = [s1067, s1212, s1348, s1598].

?- correlacao([1, 2, 3], [60, 70, 90], R).
R = 0.98.
```

---

## Part 2 – Word Game (Wordle)

Given a *mystery word* and a *guess* of the same length, the program returns a list of hints, one per letter:

| Value | Colour | Meaning |
|:---:|:---:|---|
| `2` | Green | Correct letter in the correct position |
| `1` | Yellow | Letter exists in the word, but in a different position |
| `0` | Red | Letter does not exist (or is in excess) |

There are three hint levels, each building on the previous one:

| Predicate | Behaviour |
|---|---|
| `pista1/3` | Marks only the exact matches (`2`); everything else is `0`. |
| `pista2/3` | Adds `1` for correct letters in wrong positions. |
| `pista3/3` | Same as `pista2`, but removes surplus `1`s when the guess contains more occurrences of a letter than the mystery word. |

### Helper predicates

`tamanho/2`, `verificaECalcula/4`, `quantasN/3`, `quantasC/3`, `apagaElemento/3`, `posicoesPalavra/2`.

### Examples

```prolog
?- pista1(lara, pera, L).
L = [0, 0, 2, 2].

?- pista2(ramal, arara, L).
L = [1, 1, 1, 1, 1].

?- pista3(ramal, arara, L).      % repeated letters handled correctly
L = [1, 1, 1, 0, 0].

?- pista3(babaa, aabba, L).
L = [1, 2, 2, 1, 2].

?- quantasC(pt, f, N).           % words starting with "f" in the Portuguese list
N = 47.
```

### Playing the game

```prolog
?- [jogar].
?- jogar(pt, 5, 6, pista3).
```

Arguments: `jogar(ListName, WordLength, MaxGuesses, HintType)`.

- `ListName`: `pt` (Portuguese dictionary) or `mini` (tiny list for testing).
- `WordLength`: length of the word to guess.
- `MaxGuesses`: number of attempts.
- `HintType`: `pista1`, `pista2` or `pista3`.

> **Tip:** guesses are read with `read/1`, so type them as lowercase atoms followed by a full stop, e.g. `carro.` Words with accents or capital letters need quotes, e.g. `'cão'.`

---

## Part 3 – Movie Marathon Scheduler

Schedule up to 7 movie sessions subject to a set of constraints. If fewer than 7 movies are given, the remaining slots are filled with `empty`.

### Constraint predicates

| Constraint | Meaning |
|---|---|
| `soPode(Film, Slot, Schedule)` | `Film` must be exactly in slot `Slot`. |
| `nunca(Film, Slot, Schedule)` | `Film` must never be in slot `Slot`. |
| `terror(Film, Schedule)` | Horror film: must be in slot 3, 4 or 7. |
| `seguido(F1, F2, Schedule)` | `F2` comes immediately after `F1` (no consecutiveness across the breaks after slots 4 and 7). |
| `naoSeguido(F1, F2, Schedule)` | `F1` and `F2` are not consecutive in either order. |
| `antes(F1, F2, Schedule)` | `F1` is scheduled before `F2`. |

### Solver

```prolog
maratonaFilmes(+Films, +Constraints, -Schedules)
```

Returns **all** valid schedules (or `[]` if there are none). Constraints are passed as a list of partially applied goals; the schedule is appended as the last argument via `call/N`.

### Example

```prolog
?- maratonaFilmes(
       [f1, f2, f3, f4, f5],
       [soPode(f1, 1), seguido(f1, f2), terror(f3),
        soPode(f4, 7), naoSeguido(f4, f3), nunca(f5, 6)],
       Programacao).

Programacao = [[f1,f2,empty,f3,f5,empty,f4],
               [f1,f2,f3,empty,f5,empty,f4],
               [f1,f2,f3,f5,empty,empty,f4],
               [f1,f2,f5,f3,empty,empty,f4]].
```

---

## Running the Tests

The public test suite uses [`plunit`](https://www.swi-prolog.org/pldoc/man?section=plunit):

```prolog
?- [projetoLP].
?- [testes_publicos].
?- run_tests.
```

Or, directly from the shell:

```bash
swipl -g "[projetoLP], [testes_publicos], run_tests" -t halt
```

---

## Design Notes

- **Self-contained list library.** Utilities such as `contagemElementos_de_lista/2`, `somaElementos_de_lista/2`, `pertence_a_lista/2` and `adicionaPosicoes/4` are implemented manually, as an exercise in recursion and accumulation.
- **Position-tagged letters.** Words are converted into lists of `(Letter, Position)` tuples, which makes comparing exact matches and misplaced letters a simple matter of unification.
- **Duplicate-letter handling in `pista3`.** Letter occurrence counts are compared between the mystery word and the guess, and the surplus `1`s are removed starting from the rightmost misplaced occurrences.
- **Generate-and-test scheduling.** `maratonaFilmes/3` enumerates permutations and filters them with `verificaRestricoes/2`. This is simple and correct, and fast enough for 7 slots (7! = 5040 candidates), but it does not scale to larger schedules without constraint propagation (e.g. `library(clpfd)`).
- **Sorting by permutation.** `ordena/2` sorts via permutation as a teaching exercise. It is only suitable for the short lists used in this project, and `msort/2` or `sort/4` would be the right choice in production code.

---

## Author

**Cristiano Suranyi** – [GitHub](https://github.com/Cristiano-Suranyi) · [LinkedIn](https://www.linkedin.com/in/Cristiano-Suranyi)

Instituto Superior Técnico, University of Lisbon

---

## Acknowledgements & Academic Note

This project was developed for the [Logic for Programming](https://fenix.tecnico.ulisboa.pt/disciplinas/LP2112/2025-2026/1-semestre) course at IST. 
This repository is shared for portfolio and learning purposes. If you are currently enrolled in the course, please follow your institution's academic integrity policy and do not submit this work as your own.
