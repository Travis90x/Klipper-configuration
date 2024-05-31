<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Schema GPIO</title>
    <style>
        table {
            border-collapse: collapse;
            width: 50%;
            text-align: center;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            font-size: 14px;
        }
        th {
            background-color: #f2f2f2;
        }
        .yellow {
            background-color: yellow;
        }
        .red {
            background-color: red;
        }
        .green {
            background-color: green;
            color: white;
        }
        .black {
            background-color: black;
            color: white;
        }
        .blue {
            background-color: blue;
            color: white;
        }
    </style>
</head>
<body>

<h2>Schema GPIO</h2>

<table>
    <tr>
        <th>Method 2</th>
        <th>Method 1</th>
        <th>Method 1</th>
        <th>Method 2</th>
    </tr>
    <tr>
        <td class="yellow">3.3V</td>
        <td class="yellow">3.3V</td>
        <td class="red">5V</td>
        <td class="red">5V</td>
    </tr>
    <tr>
        <td>gpio131</td>
        <td class="black">gpiochip4/gpio10</td>
        <td class="red">5V</td>
        <td class="black">gpiochip0/gpio25</td>
    </tr>
    <tr>
        <td>gpio132</td>
        <td class="black">gpiochip4/gpio11</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio24</td>
    </tr>
    <tr>
        <td>gpio97</td>
        <td class="black">gpiochip3/gpio1</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td class="black">GND</td>
        <td>gpio9</td>
        <td>gpio1</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio32</td>
        <td class="black">gpiochip1/gpio0</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio33</td>
        <td class="black">gpiochip1/gpio1</td>
        <td class="yellow">3.3V</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td class="yellow">3.3V</td>
        <td>gpio99</td>
        <td class="black">gpiochip3/gpio17</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio100</td>
        <td class="black">gpiochip3/gpio18</td>
        <td>gpio6</td>
        <td class="black">gpiochip4/gpio20</td>
    </tr>
    <tr>
        <td>gpio33</td>
        <td class="black">gpiochip1/gpio1</td>
        <td class="yellow">3.3V</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio99</td>
        <td class="black">gpiochip3/gpio17</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td class="black">GND</td>
        <td>gpio100</td>
        <td class="black">gpiochip3/gpio18</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio33</td>
        <td class="black">gpiochip1/gpio1</td>
        <td class="blue">gpio6</td>
        <td class="black">gpiochip4/gpio20</td>
    </tr>
    <tr>
        <td>gpio99</td>
        <td class="black">gpiochip3/gpio17</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio105</td>
        <td class="black">gpiochip3/gpio30</td>
        <td class="blue">gpio4</td>
        <td class="black">gpiochip0/gpio11</td>
    </tr>
    <tr>
        <td>gpio106</td>
        <td class="black">gpiochip3/gpio30</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio2</td>
        <td class="black">gpiochip3/gpio2</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio135</td>
        <td class="black">gpiochip4/gpio5</td>
        <td>gpio3</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio5</td>
        <td class="black">gpiochip0/gpio12</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td class="black">GND</td>
        <td>gpio131</td>
        <td class="black">gpiochip0/gpio8</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio5</td>
        <td class="black">gpiochip0/gpio12</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio105</td>
        <td class="black">gpiochip3/gpio30</td>
        <td class="blue">gpio4</td>
        <td class="black">gpiochip0/gpio11</td>
    </tr>
    <tr>
        <td>gpio106</td>
        <td class="black">gpiochip3/gpio30</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio2</td>
        <td class="black">gpiochip3/gpio2</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio135</td>
        <td class="black">gpiochip4/gpio5</td>
        <td>gpio3</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td>gpio5</td>
        <td class="black">gpiochip0/gpio12</td>
        <td class="black">GND</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
    <tr>
        <td class="black">GND</td>
        <td>gpio131</td>
        <td class="black">gpiochip0/gpio8</td>
        <td class="black">gpiochip0/gpio8</td>
    </tr>
</table>

</body>
</html>
