#!/usr/bin/env bash

echo "📥 Baixando o Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

echo "📦 Instalando dependências..."
flutter pub get

echo "🚀 Compilando o app para a Web..."
flutter build web