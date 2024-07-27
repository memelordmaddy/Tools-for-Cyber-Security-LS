#flag{f34r1355_5ud0ku_c0nqu3r0r}
import subprocess
from copy import deepcopy
import re

class Sudoku:
    def __init__(self, grid):
        self.grid = deepcopy(grid)
        self.empty_positions = [(row, col) for row in range(9) for col in range(9) if grid[row][col] == 0]

    def find_empty(self):
        for row, col in self.empty_positions:
            if self.grid[row][col] == 0:
                return row, col
        return None

    def is_num_valid(self, row, col, num):
        if any(self.grid[row][x] == num for x in range(9)):
            return False
        if any(self.grid[x][col] == num for x in range(9)):
            return False
        start_row, start_col = 3 * (row // 3), 3 * (col // 3)
        if any(self.grid[start_row + x//3][start_col + x%3] == num for x in range(9)):
            return False
        return True

    def solve_puzzle(self):
        cell = self.find_empty()
        if cell is None:
            return True
        row, col = cell
        for num in range(1, 10):
            if self.is_num_valid(row, col, num):
                self.grid[row][col] = num
                if self.solve_puzzle():
                    return True
                self.grid[row][col] = 0
        return False

    def display_grid(self):
        for row in self.grid:
            print(row)

    def is_solved(self):
        return all(self.grid[row][col] != 0 for row in range(9) for col in range(9))

def solve_sudoku(grid):
    sudoku_solver = Sudoku(grid)
    if sudoku_solver.solve_puzzle():
        return sudoku_solver.grid
    else:
        return None

process = subprocess.Popen(["./sudoku"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
completed_puzzles = 0

for _ in range(420):
    puzzle = []
    reading_puzzle = False

    while True:
        output_line = process.stdout.readline().decode().strip()
        if not output_line:
            break

        if 'Snuday Special Sudoku' in output_line:
            completed_puzzles += 1

        if 'Here is your Puzzle:' in output_line:
            reading_puzzle = True
            continue

        if reading_puzzle:
            if re.match(r"\| [0-9\.] [0-9\.] [0-9\.] \|", output_line):
                puzzle_row = []
                for char in output_line:
                    if char == ".":
                        puzzle_row.append(0)
                    elif char.isdigit():
                        puzzle_row.append(int(char))
                puzzle.append(puzzle_row)
            elif len(puzzle) == 9:
                break

    if len(puzzle) == 9:
        solved_puzzle = solve_sudoku(puzzle)
        if solved_puzzle:
            sudoku_solver = Sudoku(puzzle)
            sudoku_solver.solve_puzzle()
            for (row, col) in sudoku_solver.empty_positions:
                process.stdin.write(f"{row} {col} {sudoku_solver.grid[row][col]}\n".encode())
                process.stdin.flush()
                if (response := process.stdout.readline().decode().strip()) == '':
                    break
        else:
            print("No solution exists")

while (output_line := process.stdout.readline()):
    print(output_line.decode().strip())
