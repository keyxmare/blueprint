import { createRouter, createWebHistory } from 'vue-router'
const Home = () => import('../views/Home.vue')
const About = () => import('../views/About.vue')
export default createRouter({ history: createWebHistory(), routes: [
  { path: '/', name: 'home', component: Home },
  { path: '/about', name: 'about', component: About }
]})
