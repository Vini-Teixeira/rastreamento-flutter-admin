import 'package:flutter/material.dart';
import 'package:rastreamento_app_admin/screens/cta_page.dart';

// Um modelo simples para guardar os dados de cada página de onboarding
class OnboardingItem {
  final String imagePath;
  final String title;
  final String subtitle;
  final TextSpan? richSubtitle; // Para textos com estilos diferentes

  OnboardingItem({
    required this.imagePath,
    required this.title,
    this.subtitle = '',
    this.richSubtitle,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controlador para o PageView, para sabermos em qual página estamos
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Lista com os dados de todas as telas de splash
  static final List<OnboardingItem> _onboardingData = [
    OnboardingItem(
      imagePath: 'assets/images/acompanhamento_de_rotas.png',
      title: 'Bem-vindo ao seu App de Rastreamento',
      richSubtitle: const TextSpan(
        children: [
          TextSpan(text: 'Agora você pode acompanhar todas as entregas: '),
          TextSpan(
              text: 'em andamento',
              style:
                  TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          TextSpan(text: ', '),
          TextSpan(
              text: 'concluídas',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          TextSpan(text: ' e '),
          TextSpan(
              text: 'canceladas',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
    OnboardingItem(
      imagePath: 'assets/images/acompanhamento_multiplataforma.png',
      title: 'Acesse de Onde Estiver',
      richSubtitle: const TextSpan(
        children: [
          TextSpan(
              text:
                  'Acesse do celular, tablet ou computador. Seu sistema de rastreamento é '),
          TextSpan(
              text: 'MULTIPLATAFORMA',
              style:
                  TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
    OnboardingItem(
      imagePath: 'assets/images/em_tempo_real.png',
      title: 'Todas as suas entregas',
      richSubtitle: const TextSpan(
        children: [
          TextSpan(text: 'Podem ser acompanhadas em'),
          TextSpan(
              text: '\nTEMPO REAL',
              style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          TextSpan(text: '\ncom alguns cliques'),
        ],
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Função para o botão "Continuar"
  void _onNextPressed() {
    if (_currentPage < _onboardingData.length - 1) {
      // Se não for a última página, avança para a próxima
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Se for a última página, navega para a CTA_Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CtaPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Fundo escuro padrão
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              // O PageView que mostra as telas
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildPageContent(_onboardingData[index]);
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Indicadores de bolinha
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => _buildDotIndicator(index == _currentPage),
                ),
              ),
              const SizedBox(height: 48),
              // Botão de Continuar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1
                        ? 'Começar Agora'
                        : 'Continuar',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget que constrói o conteúdo de cada página
  Widget _buildPageContent(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),
          Image.asset(
            item.imagePath,
            height: MediaQuery.of(context).size.height * 0.3,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 50),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              // Estilo padrão para o texto do subtítulo
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                height: 1.5,
              ),
              children: item.richSubtitle?.children ??
                  [TextSpan(text: item.subtitle)],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  // Widget que constrói as bolinhas indicadoras
  Widget _buildDotIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.amber : Colors.grey[700],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
