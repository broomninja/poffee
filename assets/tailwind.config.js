// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const colors = require("tailwindcss/colors");
const fs = require("fs");
const path = require("path");

module.exports = {
  content: [
    "../deps/petal_components/**/*.*ex",
    "./svelte/**/*.svelte",
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
  ],
  theme: {
    extend: {
      // width: {
      //   '128': '32rem',
      //   '160': '40rem',
      // },
      // height: {
      //   '128': '32rem',
      //   '160': '10rem',
      // },
      colors: {
        transparent: 'transparent',
        current: 'currentColor',

        // We need to define the 50–900 shades for Petal components 
        primary: {
          light3x: colors.emerald[50],
          light2x: colors.emerald[100],
          light: colors.emerald[300],
          DEFAULT: colors.emerald[400],
          dark: colors.emerald[600],
          dark2x: colors.emerald[900],
          50: colors.emerald[50],
          100: colors.emerald[100],
          200: colors.emerald[200],
          300: colors.emerald[300],
          400: colors.emerald[400],
          500: colors.emerald[500],
          600: colors.emerald[600],
          700: colors.emerald[700],
          800: colors.emerald[800],
          900: colors.emerald[900],
        },
        secondary: {
          light3x: colors.sky[50],
          light2x: colors.sky[100],
          light: colors.sky[300],
          DEFAULT: colors.sky[500],
          dark: colors.sky[700],
          dark2x: colors.sky[900],
          50: colors.sky[50],
          100: colors.sky[100],
          200: colors.sky[200],
          300: colors.sky[300],
          400: colors.sky[400],
          500: colors.sky[500],
          600: colors.sky[600],
          700: colors.sky[700],
          800: colors.sky[800],
          900: colors.sky[900],
        },
        alert: {
          light3x: colors.pink[50],
          light2x: colors.pink[100],
          light: colors.pink[300],
          DEFAULT: colors.pink[500],
          dark: colors.pink[700],
          dark2x: colors.pink[900],
          50: colors.pink[50],
          100: colors.pink[100],
          200: colors.pink[200],
          300: colors.pink[300],
          400: colors.pink[400],
          500: colors.pink[500],
          600: colors.pink[600],
          700: colors.pink[700],
          800: colors.pink[800],
          900: colors.pink[900],
        },
        info: {
          light3x: colors.cyan[50],
          light2x: colors.cyan[100],
          light: colors.cyan[300],
          DEFAULT: colors.cyan[500],
          dark: colors.cyan[700],
          dark2x: colors.cyan[900],
          50: colors.cyan[50],
          100: colors.cyan[100],
          200: colors.cyan[200],
          300: colors.cyan[300],
          400: colors.cyan[400],
          500: colors.cyan[500],
          600: colors.cyan[600],
          700: colors.cyan[700],
          800: colors.cyan[800],
          900: colors.cyan[900],
        },
        success: {
          light3x: colors.teal[50],
          light2x: colors.teal[100],
          light: colors.teal[300],
          DEFAULT: colors.teal[500],
          dark: colors.teal[700],
          dark2x: colors.teal[900],
          50: colors.teal[50],
          100: colors.teal[100],
          200: colors.teal[200],
          300: colors.teal[300],
          400: colors.teal[400],
          500: colors.teal[500],
          600: colors.teal[600],
          700: colors.teal[700],
          800: colors.teal[800],
          900: colors.teal[900],
        },
        warning: {
          light3x: colors.amber[50],
          light2x: colors.amber[100],
          light: colors.amber[300],
          DEFAULT: colors.amber[500],
          dark: colors.amber[700],
          dark2x: colors.amber[900],
          50: colors.amber[50],
          100: colors.amber[100],
          200: colors.amber[200],
          300: colors.amber[300],
          400: colors.amber[400],
          500: colors.amber[500],
          600: colors.amber[600],
          700: colors.amber[700],
          800: colors.amber[800],
          900: colors.amber[900],
        },
        danger: {
          light3x: colors.rose[50],
          light2x: colors.rose[100],
          light: colors.rose[300],
          DEFAULT: colors.rose[500],
          dark: colors.rose[700],
          dark2x: colors.rose[900],
          50: colors.rose[50],
          100: colors.rose[100],
          200: colors.rose[200],
          300: colors.rose[300],
          400: colors.rose[400],
          500: colors.rose[500],
          600: colors.rose[600],
          700: colors.rose[700],
          800: colors.rose[800],
          900: colors.rose[900],
        },
        white: {
          DEFAULT: colors.white,
          dark: colors.slate[100],
        },
      }, // colors
    }, // extend
  }, // theme
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),

    // Embeds Hero Icons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let hero_iconsDir = path.join(__dirname, "./vendor/heroicons/optimized");
      let hero_values = {};
      let hero_icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
      ];
      hero_icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(hero_iconsDir, dir)).map((file) => {
          let name = path.basename(file, ".svg") + suffix;
          hero_values[name] = { name, fullPath: path.join(hero_iconsDir, dir, file) };
        });
      });

      matchComponents(
        {
          hero: ({ name, fullPath }) => {
            let content = fs
              .readFileSync(fullPath)
              .toString()
              .replace(/\r?\n|\r/g, "");

            console.log("hero: " + name + " fullpath: " + fullPath)

            return {
              [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              "-webkit-mask": `var(--hero-${name})`,
              mask: `var(--hero-${name})`,
              "background-color": "currentColor",
              "vertical-align": "middle",
              display: "inline-block",
              width: theme("spacing.5"),
              height: theme("spacing.5"),
            };
          },
        },
        { values: hero_values }
      );

      let tabler_iconsDir = path.join(__dirname, './vendor/tabler/icons');
      let tabler_values = {};
      let tabler_icons = [['', '']];

      tabler_icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(tabler_iconsDir, dir)).map((file) => {
          let name = path.basename(file, '.svg') + suffix;
          tabler_values[name] = { name, fullPath: path.join(tabler_iconsDir, dir, file) };
        });
      });

      matchComponents(
        {
          tabler: ({ name, fullPath }) => {
            let content = fs
            .readFileSync(fullPath)
            .toString()
            .replace(/\r?\n|\r/g, '');

            console.log("tabler: " + name + " fullpath: " + fullPath)

            return {
              [`--tabler-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              '-webkit-mask': `var(--tabler-${name})`,
              mask: `var(--tabler-${name})`,
              'background-color': 'currentColor',
              'vertical-align': 'middle',
              display: 'inline-block',
              width: theme('spacing.5'),
              height: theme('spacing.5'),
            };          
          },
        },
        { values: tabler_values }
      );
    }),
  ],
};
