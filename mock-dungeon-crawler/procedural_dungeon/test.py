# Simple grid visualizer with walls and X's

# Grid size
rows = 10
cols = 10

# Create empty grid
grid = [[' ' for _ in range(cols)] for _ in range(rows)]

def print_grid():
    print("\n".join(["|".join(row) for row in grid]))
    print("-" * (cols * 2 - 1))

def place_item(row, col, item):
    if 0 <= row < rows and 0 <= col < cols:
        grid[row][col] = item
    else:
        print("Invalid position!")

# Example usage:
place_item(2, 3, '#')  # place a wall
place_item(5, 5, 'X')  # place an X
place_item(0, 0, '#')  # another wall

print_grid()
